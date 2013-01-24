require 'csv'
require 'pcsv/version'

class PCSV
  ##############################################################################
  #
  # Static Methods
  #
  ##############################################################################
  
  # Opens a CSV file and runs the block on each cell in parallel. Returns a
  # copy of the CSV file.
  def self.each(path, options={})
    thread_count = options[:thread_count] || 10
    csv = CSV.read(path, options)
    
    # Build a worker queue.
    queue = []
    csv.each_with_index do |row, row_index|
      row.fields.each_with_index do |field, col_index|
        queue << {
          row_index:row_index,
          col_index:col_index,
          row:row,
          value:field
        }
      end
    end
    
    # Launch threads and iterate over queue until it's done.
    mutex = Mutex.new()
    threads = []
    thread_count.times do |thread_index|
      threads << Thread.new() do
        loop do
          # Grab an item from the front of the queue.
          item = nil
          mutex.synchronize do
            item = queue.shift()
          end
          break if item.nil?
        
          # Invoke the block with the row info.
          yield item, mutex
        end
      end
    end

    threads.each { |t| t.join }
    
    return csv
  end
end