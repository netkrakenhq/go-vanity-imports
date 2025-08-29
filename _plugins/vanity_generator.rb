# frozen_string_literal: true
#
# Jekyll plugin that reads _data/vanity.yaml and creates virtual pages:
#   <destination>/<path>/index.html

require "jekyll"
require "uri"

module Jekyll
  class VanityGenerator < Generator
    safe true
    priority :low

    def generate(site)
      host = site.data.dig("vanity", "host") || URI(site.config["url"].to_s).host
      if host.to_s.empty?
        Jekyll.logger.error "vanity_generator", "host missing in _data/vanity.yaml"
        raise Jekyll::Errors::FatalException, "host missing in _data/vanity.yaml"
      end

      paths = site.data.dig("vanity", "paths") || {}
      unless paths.is_a?(Hash) && !paths.empty?
        Jekyll.logger.warn "vanity_generator", "paths missing in _data/vanity.yaml"
        return
      end

      sources = site.data.dig("vanity", "sources") || {}

      paths.each do |path, opts|
        opts ||= {}

        path = path.to_s.strip.gsub(%r{^/+|/+$}, "")
        vcs = (opts["vcs"] || "git").to_s.strip
        prefix = "#{host}/#{path}".strip
        repo = (opts["repo"] || "").to_s.strip

        if repo.empty?
          Jekyll.logger.error "vanity_generator", "repo is missing for #{path.inspect}"
          raise Jekyll::Errors::FatalException, "repo is missing for #{path.inspect}"
        end

        branch = (opts["branch"] || "main").to_s.strip
        source = opts.key?("source") ? opts["source"] : URI(repo).host.to_s.downcase

        page = PageWithoutAFile.new(site, site.source, path, "index.md")
        page.data["layout"] = "default"
        page.data["custom_meta"] = {
          "robots" => "noindex, nofollow",
          "go-import" => "#{prefix} #{vcs} #{repo}",
        }

        if source && source != false
          unless source.is_a?(Hash)
            source = find_source(sources, source.to_s.strip)
            unless source
              raise Jekyll::Errors::FatalException, "unsupported source for #{path.inspect}"
            end
          end

          home, dir, file = source.values_at("home", "dir", "file").map {
            |v| v.to_s.strip
          }

          if home.empty? || dir.empty? || file.empty?
            raise Jekyll::Errors::FatalException, "invalid source for #{path.inspect}"
          end

          page.data["custom_meta"]["go-source"] =
            "#{prefix} #{home} #{dir} #{file}" % {
              branch: branch,
              slug: URI(repo).path.gsub(%r{^/+|/+$}, "")
            }
        end

        tpl_path = File.join(site.source, "_includes", "vanity-module.md.liquid")
        tpl_vars = { "page" => page.data, "repo" => repo, "prefix" => prefix }

        page.content = site.liquid_renderer
                           .file(tpl_path)
                           .parse(File.read(tpl_path))
                           .render!(tpl_vars, registers: { :site => site })

        site.pages << page
        Jekyll.logger.info "vanity_generator", "generated #{prefix}/index.md"
      end
    end

    def find_source(sources, host)
      pair = sources.detect do |pattern, _|
        str = pattern.to_s.strip
        if str.start_with?("~")
          re = Regexp.new(str[1..])
          re.match?(host)
        else
          str.downcase == host.downcase
        end
      end
      pair&.last
    end

  end
end
