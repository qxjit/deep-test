module DeepTest
  module Distributed
    class FilenameResolver
      def initialize(base_path)
        @base_path = base_path
      end

      def resolve(filename)
        return resolve("/" + filename) unless filename[0] == ?/

        return filename.sub(@cached_replaced_path, @base_path) if @cached_replaced_path

        each_potential_filename(filename) do |potential_filename|
          if File.exist?(potential_filename)
            cache_resolution(filename, potential_filename)
            return potential_filename 
          end
        end

        raise "Filename resolution failed.  Cannot resolve #{filename} within #{@base_path}"
      end

      def cache_resolution(original_filename, resolved_filename)
        @cached_replaced_path = original_filename.sub(
           resolved_filename.sub(@base_path, ""), ""
        )
      end

      def each_potential_filename(filename)
        basename = File.basename(filename)
        dirs = File.dirname(filename).split('/')

        begin
          dirs.shift
          yield [@base_path, dirs, basename].flatten.join('/')
        end until dirs.empty?
      end
    end
  end
end
