require 'thor'
require 'fileutils'
require 'pry'

module Bauditor
  class CLI < ::Thor
    default_task :audit

    desc 'audit', 'run bundle-audit on multiple repositories'

    method_option :repo_path,
      type: :string,
      desc: 'Path to directory where fetched repositories will be stored'
    method_option :persist,
      type: :boolean,
      desc: 'Persist repositories, or not.',
      default: true
    method_option :repos,
      type: :array,
      aliases: 'r',
      desc: 'Space seperate list of repositories'
    method_option :config,
      type: :string,
      aliases: 'c',
      desc: 'Path to file containing repositories one per line.'

    def audit
      if options[:repos].nil? && options[:config].nil?
        puts 'Please provide either a list of repos (--repos=one two)'
        puts 'or a configuraiton file --config=repos.cfg'
        exit 1
      end

      @cwd = Dir.getwd

      setup_dirs
      Dir.chdir repo_path

      update_db
      set_repos

      self.summary = {}
      audit_repos

      summary_report
    ensure
      teardown
    end

    private

    attr_accessor :repos, :summary

    def add_repos_from_config
      self.repos += File.readlines(File.join(@cwd, options[:config])).map(&:chomp)
    end

    def audit_repos
      repos.each do |repo|
        Dir.chdir repo_path
        unless repo.match(/([^\/]+)\.git$/)
          hr
          say "[BAUDITOR] #{repo} does not appear to be a git repo", :red
          next
        end
        name = $1
        hr
        say "[BAUDITOR] fetching and auditing #{name}", :yellow
        hr

        if File.exist?(name)
          Dir.chdir name
          `git pull origin master`

          unless $?.success?
            say "[BAUDITOR] error pulling origin master from  git repo #{name}", :red
            next
          end
        else
          `git clone #{repo} --branch master --single-branch #{name}`

          unless $?.success?
            say "[BAUDITOR] error fetching git repo #{name}", :red
            next
          end
          Dir.chdir name
        end

        rm_lock = false
        unless File.exist?('Gemfile.lock')
          say "[BAUDITOR] running bundle lock for #{name}", :yellow
          system 'bundle lock'
          rm_lock = true
        end
        success = system 'bundle-audit'

        FileUtils.rm('Gemfile.lock') if rm_lock

        self.summary[name] = success
      end
      hr
    end

    def persist?
      options['persist']
    end

    def repo_path
      options.fetch(:repo_path, '/tmp/bauditor')
    end

    def hr
      say "---------------------------------------------------", :blue
    end


    def set_repos
      self.repos = options.fetch(:repos, [])

      add_repos_from_config if options[:config]

      self.repos.uniq!

      if repos.empty?
        puts 'No repositories found'
        exit 1
      end
    end

    def setup_dirs
      unless File.exist?(repo_path)
        Dir.mkdir(repo_path)
        @dir_created = true
      end
      bundle_path = File.join(repo_path, '.bundle')
      Dir.mkdir(bundle_path) unless File.exist?(bundle_path)
    end

    def summary_report
      return if summary.empty?

      say '[BAUDITOR] summary report:', [:green, :bold]

      long_name = summary.keys.max_by(&:length)
      pad = long_name.length

      h = sprintf("| %-#{pad}s | Vulnerable? |", 'Repo')
      say '_' * h.length, :cyan
      say h, :cyan
      say '-' * h.length, :cyan

      summary.each do |name, status|
        say '| ', :cyan
        say sprintf("%-#{pad}s ", name), :yellow
        say '| ', :cyan
        if status
          say sprintf('   %-9s', 'No '), :green
        else
          say sprintf('   %-9s', 'YES '), [:red, :bold]
        end
        say '|', :cyan
      end
      say '-' * h.length, :cyan
    end

    def teardown
      Dir.chdir File.dirname(__FILE__)
      return if persist?
      if @dir_created
        FileUtils.rm_rf repo_path
      else
        Pathname.new(repo_path).children.each { |p| p.rmtree }
      end
    end

    def update_db
      say '[BAUDITOR] Updating the bundle-audit database', :yellow
      system 'bundle exec bundle-audit update'
    end
  end
end
