require 'xcodeproj'

module Pod

  class ProjectManipulator
    attr_reader :configurator, :xcodeproj_path, :platform, :remove_demo_target, :string_replacements, :prefix

    def self.perform(options)
      new(options).perform
    end

    def initialize(options)
      @xcodeproj_path = options.fetch(:xcodeproj_path)
      @configurator = options.fetch(:configurator)
      @platform = options.fetch(:platform)
      @remove_demo_target = options.fetch(:remove_demo_project)
      @prefix = options.fetch(:prefix)
    end

    def run
      @string_replacements = {
        "PROJECT_OWNER" => @configurator.user_name,
        "TODAYS_DATE" => @configurator.date,
        "TODAYS_YEAR" => @configurator.year,
        "PROJECT" => @configurator.pod_name,
        "CPD" => @prefix
      }
      replace_internal_project_settings

      @project = Xcodeproj::Project.open(@xcodeproj_path)
      add_podspec_metadata
      configure_podFile
      @project.save

      rename_files
      rename_project_folder
      
            
    end

    def add_podspec_metadata
      project_metadata_item = @project.root_object.main_group.children.select { |group| group.name == "Podspec Metadata" }.first
      project_metadata_item.new_file "../" + @configurator.pod_name  + ".podspec"
      project_metadata_item.new_file "../README.md"
      project_metadata_item.new_file "../LICENSE"
    end

#configure podFile
    def configure_podFile
      podfile_path = project_folder + "/Podfile"
      puts "this is the pod filePath " + podfile_path
      podfile_text = <<-RUBY
      # edit podfile   在这里添加基础库
use_frameworks!
platform:ios, '8.0'
target '#{@configurator.pod_name}' do
  pod '#{@configurator.pod_name}', :path => '../'
  pod 'AFNetworking'
  #  pod ‘basePod’
  ${INCLUDED_PODS}
end
#configure pod组件的配置
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if config.name == 'Debug'
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=2']
                config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            end
        end
    end
end

RUBY
      File.open(podfile_path, "w") { |file| file.puts podfile_text }
    end

    def project_folder
      File.dirname @xcodeproj_path
    end

    def rename_files
      # shared schemes have project specific names
      scheme_path = project_folder + "/PROJECT.xcodeproj/xcshareddata/xcschemes/"
      File.rename(scheme_path + "PROJECT.xcscheme", scheme_path +  @configurator.pod_name + ".xcscheme")

      # rename xcproject
      File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" +  @configurator.pod_name + ".xcodeproj")

      unless @remove_demo_target
        # change app file prefixes
        ["CPDAppDelegate.h", "CPDAppDelegate.m", "CPDViewController.h", "CPDViewController.m"].each do |file|
          before = project_folder + "/PROJECT/" + file
          next unless File.exists? before
          after = project_folder + "/PROJECT/" + file.gsub("CPD", prefix)
          File.rename before, after
        end

        # rename project related files
        ["PROJECT-Info.plist", "PROJECT-Prefix.pch"].each do |file|
          before = project_folder + "/PROJECT/" + file
          next unless File.exists? before

          after = project_folder + "/PROJECT/" + file.gsub("PROJECT", @configurator.pod_name)
          File.rename before, after
        end
      end

    end

    def rename_project_folder
      if Dir.exist? project_folder + "/PROJECT"
        File.rename(project_folder + "/PROJECT", project_folder + "/" + @configurator.pod_name)
      end
    end

    def replace_internal_project_settings
      Dir.glob(project_folder + "/**/**/**/**").each do |name|
        next if Dir.exists? name
        text = File.read(name)

        for find, replace in @string_replacements
            text = text.gsub(find, replace)
        end

        File.open(name, "w") { |file| file.puts text }
      end
    end

  end

end
