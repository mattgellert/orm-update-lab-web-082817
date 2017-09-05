require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_accessor :name, :grade
  attr_reader :id


  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def self.create_table
    sql = <<-sql
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    sql

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if !!self.id
      sql = <<-sql
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ?
      sql

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    else
      sql = <<-sql
        INSERT INTO students (name, grade)
        VALUES (?,?)
      sql

      DB[:conn].execute(sql,self.name,self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-sql
      SELECT *
      FROM students
      WHERE name = ?
    sql

    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-sql
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    sql

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
