#!/usr/bin/env ruby

class TodoList
  def initialize
    @tasks = []
  end

  def add_task(task)
    @tasks << task
    puts "Task added: #{task}"
  end

  def list_tasks
    if @tasks.empty?
      puts "No tasks in the list."
    else
      puts "Tasks:"
      @tasks.each_with_index do |task, index|
        puts "#{index + 1}. #{task}"
      end
    end
  end

  def remove_task(index)
    if index >= 1 && index <= @tasks.length
      removed_task = @tasks.delete_at(index - 1)
      puts "Task removed: #{removed_task}"
    else
      puts "Invalid task number."
    end
  end
end

todo_list = TodoList.new

loop do
  puts "\nTodo List Manager"
  puts "1. Add task"
  puts "2. List tasks"
  puts "3. Remove task"
  puts "4. Exit"
  print "Enter your choice: "

  choice = gets.chomp.to_i

  case choice
  when 1
    print "Enter task: "
    task = gets.chomp
    todo_list.add_task(task)
  when 2
    todo_list.list_tasks
  when 3
    print "Enter task number to remove: "
    index = gets.chomp.to_i
    todo_list.remove_task(index)
  when 4
    puts "Goodbye!"
    exit
  else
    puts "Invalid choice. Please try again."
  end
end

