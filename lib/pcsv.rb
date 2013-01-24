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
    return process(:each, path, options, &Proc.new)
  end

  # Opens a CSV file and maps the results of a block on each cell in parallel.
  # Returns a copy of the CSV file.
  def self.map(path, options={})
    return process(:map, path, options, &Proc.new)
  end

  # Performs a given action on each cell of a CSV file.
  def self.process(action, path, options={})
    thread_count = options.delete(:thread_count) || 10

    # Open CSV & build a worker queue.
    csv = CSV.read(path, options)
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
          begin
            result = yield item, mutex
          
            if action == :map
              mutex.synchronize {
                item[:row][item[:col_index]] = result
              }
            end

          rescue StandardError => e
            warn("[ERROR] #{e.message} [R#{item[:row_index]},C#{item[:col_index]}]")
          end
        end
      end
    end

    threads.each { |t| t.join }
    
    return csv
  end
end