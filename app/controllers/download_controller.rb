# frozen_string_literal: true

class DownloadController < ApplicationController
  DEFAULT_LOG_FILENAME = Rails.configuration.x.terraform_log_filename

  def download
    files
    zip_files
    @zip_name = "#{t('terraform_files').downcase.gsub(' ', '_')}"\
                "-#{DateTime.now.iso8601}.zip"
    send_data @compressed_filestream.read, filename: @zip_name
  end

  def files
    sources = Source.all.order(:filename)
    @files = sources.map do |source|
      Rails.configuration.x.source_export_dir + source.filename
    end

    @files.push Pathname.new(DEFAULT_LOG_FILENAME) if
      File.exist?(DEFAULT_LOG_FILENAME)
  end

  def zip_files
    @compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      @files.each do |file|
        zos.put_next_entry File.basename(file)
        zos.print file.read
      end
    end

    @compressed_filestream.rewind
  end
end
