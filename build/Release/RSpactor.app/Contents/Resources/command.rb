module RSpactor
  module Core
    class Command
      
      def self.run_spec(locations)
        base_spec_root  = extract_spec_root_from_path(locations.first)
        spec_runner_bin = script_runner(locations.first)
        locations = locations.join(" ")
        cmd =   "RAILS_ENV=test; "
        cmd <<  "#{spec_runner_bin} "
        cmd <<  "#{locations} #{spec_opts(base_spec_root)} "
        cmd <<  "-r #{File.dirname(__FILE__)}/remote_result.rb -f RSpactor::Core::RemoteResult:STDOUT"
        puts cmd
        system(cmd)
      end
  
      def self.spec_opts(base_spec_root)
        if File.exist?("#{base_spec_root}spec.opts")
          return "-O #{base_spec_root}spec.opts"
        else
          return "-c -f progress"
        end
      end
  
      def self.script_runner(file)
        root = file[0..file.index("spec") - 1]
        if File.exist?(root + "script/spec")
          return root + "script/spec"
        else
          "spec"
        end
      end  
      
      # Move this method into inspection
      def self.extract_spec_root_from_path(file)
        file[0..file.index("spec") + 4]
      end  
      
    end    
  end
end