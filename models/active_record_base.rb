require_relative 'db_connection'
require 'active_support/inflector'
require 'active_support/inflector'


class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @class_name = options[:class_name] || name.to_s.camelcase
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    @self_class_name = self_class_name
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    belongs_options = BelongsToOptions.new(name, options)
    assoc_options[name] = belongs_options
    define_method name do
      foreign = self.send(belongs_options.foreign_key)
      owner_class = belongs_options.model_class
      if owner_class.find(foreign)
        belongs_options.model_class.where(id: foreign).first
      else
        nil
      end
    end
  end

  def has_many(name, options = {})
     options = HasManyOptions.new(name, self, options)
     assoc_options[name] = options

    define_method name do
      primary = send(options.primary_key)
      results = options.model_class.where(options.foreign_key => primary)
      results
    end
  end

  def assoc_options
    @options ||= {}
  end

  def has_one_through(name, through_name, source_name)


    define_method name do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      start_key = self.send(through_options.foreign_key)
      mid_class = through_options.model_class
      if mid_class.find(start_key)
        mid_object = mid_class.where(id: start_key).first
      else
        return nil
      end

      end_key = mid_object.send(source_options.foreign_key)
      end_class = source_options.model_class
      if end_class.find(end_key)
        end_class.where(id: end_key).first
      else
        nil
      end
    end
  end

  def has_many_through(name, through_name, source_name)

    define_method name do
      end_objects = []
      mid_objects = send(through_name)
      return nil unless mid_objects
      mid_objects.each do |mid_object|
       end_objects = end_objects + mid_object.send(source_name)
      end
      end_objects

    end
  end
end


class SQLObject
  extend Associatable

  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns.first.map {|el| el.to_sym}
  end

  def self.finalize!
    columns.each do |column_name|
      define_method column_name do
        attributes[column_name]
      end

      define_method "#{column_name}=" do |value|
        attributes[column_name] = value
      end
    end
  end

  def self.class_to_table
    # name = self.to_s
    name.tableize
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= class_to_table
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(rows)
  end

  def self.parse_all(results)
    objects = []
    results.each do |attrs|
      objects << self.new(attrs)
    end
    objects
  end

  def self.find(id)
    object = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    # return nil if object.empty?
    object.empty? ? nil : self.new(object.first)
  end

  def initialize(params = {})
    params.each do |key, value|
      sym = key.to_sym
      raise "unknown attribute '#{sym}'" unless self.class.columns.include?(sym)
      self.send("#{key}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def columns_and_values
    col_names = self.class.columns.map{|name| name.to_s}
    col_names.shift

    attr_values = []
    attribute_values.map do |value|
      current = value.is_a?(String) ? "'#{value}'" : value
      attr_values << current
    end

    [col_names, attr_values]
  end

  def insert
    col_names = columns_and_values[0].join(", ")
    attr_values = columns_and_values[1].join(", ")
    DBConnection.execute(<<-SQL)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{attr_values})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = columns_and_values[0]
    attr_values = columns_and_values[1]
    attr_values.shift

    update_statement = []
    col_names.each_with_index { |col, i| update_statement << "#{col} = #{attr_values[i]}" }


    DBConnection.execute(<<-SQL)
      UPDATE
        #{self.class.table_name}
      SET
      #{update_statement.join(", ")}
      WHERE
        id = #{attribute_values.first}
    SQL
  end

  def save

    if id
      update
    else
      insert
    end
  end

  def self.where(params)
    where_statement = []
    params.each do |col, value|
      current_value =  value.is_a?(String) ? "'#{value}'" : value
      where_statement << "#{col} = #{current_value}"
    end

    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_statement.join(" AND ")}
    SQL

    parse_all(rows)
  end
end
