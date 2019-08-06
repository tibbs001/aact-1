require 'action_view'
require 'open-uri'
require 'fileutils'
include ActionView::Helpers::NumberHelper
module Util
  class FileManager

    attr_accessor :root_dir

    def self.initialize_static_file_directories
      @root_dir = AACT::Application::AACT_STATIC_FILE_DIR
      if ! File.exists?(@root_dir)
        fu=FileUtils.new
        fu.mkdir @root_dir
        fu.mkdir_p "#{@root_dir}/static_db_copies/daily"
        fu.mkdir_p "#{@root_dir}/static_db_copies/monthly"
        fu.mkdir_p "#{@root_dir}/exported_files/daily"
        fu.mkdir_p "#{@root_dir}/exported_files/monthly"
        fu.mkdir_p "#{@root_dir}/db_backups"
        fu.mkdir_p "#{@root_dir}/documentation"
        fu.mkdir_p "#{@root_dir}/tmp"
        fu.mkdir_p "#{@root_dir}/other"
        fu.mkdir_p "#{@root_dir}/xml_downloads"
      end
      return @root_dir
    end

    def nlm_protocol_data_url
      "https://prsinfo.clinicaltrials.gov/definitions.html"
    end

    def nlm_results_data_url
      "https://prsinfo.clinicaltrials.gov/results_definitions.html"
    end

    def static_copies_directory
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{Rails.public_path}/static/static_db_copies/monthly"
      else
        "#{Rails.public_path}/static/static_db_copies/daily"
      end
    end

    def flat_files_directory
      if created_first_day_of_month? Time.zone.now.strftime('%Y%m%d')
        "#{Rails.public_path}/static/exported_files/monthly"
      else
        "#{Rails.public_path}/static/exported_files/daily"
      end
    end

    def pg_dump_file
      "#{Rails.public_path}/static/tmp/postgres.dmp"
    end

    def dump_directory
      "#{Rails.public_path}/static/tmp"
    end

    def backup_directory
      "#{Rails.public_path}/static/db_backups"
    end

    def xml_file_directory
      "#{Rails.public_path}/static/xml_downloads"
    end

    def admin_schema_diagram
      "#{Rails.public_path}/static/documentation/aact_admin_schema.png"
    end

    def schema_diagram
      "#{Rails.public_path}/static/documentation/aact_schema.png"
    end

    def data_dictionary
      "#{Rails.public_path}/static/documentation/aact_data_definitions.xlsx"
    end

    def table_dictionary
      "#{Rails.public_path}/static/documentation/aact_tables.xlsx"
    end

    def default_mesh_terms
      "#{Rails.public_path}/mesh/mesh_terms.txt"
    end

    def default_mesh_headings
      "#{Rails.public_path}/mesh/mesh_headings.txt"
    end

    def default_data_definitions
      Roo::Spreadsheet.open("#{Rails.public_path}/static/documentation/aact_data_definitions.xlsx")
    end

    def files_in(sub_dir, type=nil)
      # type ('monthly' or 'daily') identify the subdirectory to use to get the files.
      entries=[]
      if type.blank?
        dir="#{Rails.public_path}/static/#{sub_dir}"
      else
        dir="#{Rails.public_path}/static/#{sub_dir}/#{type}"
      end
      file_names=Dir.entries(dir) - ['.','..']
      file_names.each {|file_name|
        begin
          file_url="/static/#{sub_dir}/#{type}/#{file_name}"
          size=File.open("#{dir}/#{file_name}").size
          date_string=file_name.split('_').first
          date_created=(date_string.size==8 ? Date.parse(date_string).strftime("%m/%d/%Y") : nil)
          if downloadable?(file_name)
            entries << {:name=>file_name,:date_created=>date_created,:size=>number_to_human_size(size), :url=>file_url}
          else
            puts "Not a downloadable file: #{file_name}"
          end
        rescue => e
          # just skip if unexpected file encountered
          puts "Skipping because #{e}"
        end
      }
      entries.sort_by {|entry| entry[:name]}.reverse!
    end

    def downloadable? file_name
      (file_name.size == 34 and file_name[30..34] == '.zip') or (file_name.size == 28 and file_name[24..28] == '.zip')
    end

    def self.db_log_file_content(params)
      return [] if params.nil? or params[:day].nil?
      day=params[:day].capitalize
      file_name="static/logs/postgresql-#{day}.log"
      if File.exist?(file_name)
        File.open(file_name)
      else
        []
      end
    end

    def make_file_from_website(fname, url)
      return_file="#{Rails.public_path}/static/tmp/#{fname}"
      File.delete(return_file) if File.exist?(return_file)
      open(url) {|site|
        open(return_file, "wb"){|out_file|
            d=site.read
            out_file.write(d)
        }
      }
      return File.open(return_file)
    end

    def get_dump_file_from(static_file)
      return static_file if `file --brief --mime-type "#{static_file}"` == "application/octet-stream\n"
      if `file --brief --mime-type "#{static_file}"` == "application/zip\n"
         Zip::File.open(static_file) { |zipfile|
           zipfile.each { |file|
             return file if file.name=='postgres_data.dmp'
           }
        }
      end
    end

    def created_first_day_of_month?(str)
      day=str.split('/')[1]
      return day == '01'
    end

    def save_static_copy
      schema_diagram_file=File.open("#{schema_diagram}")
      admin_schema_diagram_file=File.open("#{admin_schema_diagram}")
      data_dictionary_file=File.open("#{data_dictionary}")
      nlm_protocol_file=make_file_from_website("nlm_protocol_definitions.html", nlm_protocol_data_url)
      nlm_results_file=make_file_from_website("nlm_results_definitions.html", nlm_results_data_url)

      date_stamp=Time.zone.now.strftime('%Y%m%d')
      zip_file_name="#{static_copies_directory}/#{date_stamp}_clinical_trials.zip"
      File.delete(zip_file_name) if File.exist?(zip_file_name)
      Zip::File.open(zip_file_name, Zip::File::CREATE) {|zipfile|
        zipfile.add('schema_diagram.png',schema_diagram_file)
        zipfile.add('admin_schema_diagram.png',admin_schema_diagram_file)
        zipfile.add('data_dictionary.xlsx',data_dictionary_file)
        zipfile.add('postgres_data.dmp',pg_dump_file)
        zipfile.add('nlm_protocol_definitions.html',nlm_protocol_file)
        zipfile.add('nlm_results_definitions.html',nlm_results_file)
      }
      return zip_file_name
    end

  end
end
