module Pod

  class ConfigureIOS
    attr_reader :configurator

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @configurator = options.fetch(:configurator)
    end

    def perform


    framework = :None
     
    configurator.set_test_framework("xctest", "m")
  
      keep_demo = :yes
      snapshots = :no


      prefix = "SA"

#      loop do
#        prefix = configurator.ask("What is your class prefix")
#
#        if prefix.include?(' ')
#          puts 'Your class prefix cannot contain spaces.'.red
#        else
#          break
#        end
#      end

      Pod::ProjectManipulator.new({
        :configurator => @configurator,
        :xcodeproj_path => "templates/ios/Example/PROJECT.xcodeproj",
        :platform => :ios,
        :remove_demo_project => (keep_demo == :no),
        :prefix => prefix
      }).run
      
      # There has to be a single file in the Classes dir
      # or a framework won't be created, which is now default
      `touch Pod/Classes/ReplaceMe.m`

      `mv ./templates/ios/* ./`
    end
  end

end
