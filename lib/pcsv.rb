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
    options[:headers] = true
    thread_count = options.delete(:thread_count) || 10
    if_proc = options.delete(:if)
    on_count_proc = options.delete(:on_count)
    progress_bar_visible = options.has_key?(:progress_bar) ? options.delete(:progress_bar) : true
    progress_bar = nil

    # Open CSV & build a worker queue.
    csv = CSV.read(path, options)
    queue = []
    headers = nil
    csv.each_with_index do |row, row_index|
      headers ||= csv.headers
      
      row.fields.each_with_index do |field, col_index|
        item = {
          row:row,
          row_index:row_index,
          col_index:col_index,
          value:field.to_s,
          header:headers[col_index]
        }
        next if if_proc.nil? || !if_proc.call(item)
        queue << item
      end
    end
    progress_bar = ::ProgressBar.create(:total => queue.length, :format => '%a |%B| %E %P%%') if progress_bar_visible
    on_count_proc.call(queue.length) unless on_count_proc.nil?
    
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

            mutex.synchronize { progress_bar.increment } unless progress_bar.nil?

          rescue StandardError => e
            mutex.synchronize { progress_bar.clear } unless progress_bar.nil?
            warn("[ERROR] #{e.message} [R#{item[:row_index]},C#{item[:col_index]}]")
          end
        end
      end
    end

    begin
      threads.each { |t| t.join }
    rescue SystemExit, Interrupt
      threads.each { |thread| thread.kill }
    end
    
    return csv
  end
end