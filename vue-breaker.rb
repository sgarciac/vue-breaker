#!/usr/bin/env ruby
unless ARGV.length == 1
  puts "usage: vue-breaker.rb <vue-file>"
  exit 1
end

path = ARGV[0]
extension = File.extname(path)

unless (File.file?(path) && extension =~ /.vue/i)
  puts "Not a vue file"
  exit 1
end


name = File.basename(path)
basename = File.basename(path,".*")
dir = File.dirname(path)

templatepath = dir + "/" + basename + ".html"
scriptpath = dir + "/" + basename + ".ts"
stylepath = dir + "/" + basename + ".scss"

state = :outside
template = []
script = []
style = []

File.readlines(path).each do |line|
  if state == :outside && line =~ /\s*<template[^>]*>\s*/i
    state = :insidetemplate
    next
  end

  if state == :insidetemplate && line =~ /\s*<\/template>\s*/i
    state = :outside
    next
  end

  if state == :outside && line =~ /\s*<script[^>]*>\s*/i
    state = :insidescript
    next
  end

  if state == :insidescript && line =~ /\s*<\/script>\s*/i
    state = :outside
    next
  end

    if state == :outside && line =~ /\s*<style[^>]*>\s*/i
    state = :insidestyle
    next
  end

  if state == :insidestyle && line =~ /\s*<\/style>\s*/i
    state = :outside
    next
  end

  current = {insidetemplate: template, insidescript: script, insidestyle: style}[state]
  if current
    current.push(line)
  end
end

if File.file?(templatepath)
  puts templatepath + " already exists!"
else
  File.write(templatepath, template.join)
end

if File.file?(scriptpath)
  puts scriptpath + " already exists!"
else
  File.write(scriptpath, script.join)
end

if File.file?(stylepath)
  puts stylepath + " already exists!"
else
  File.write(stylepath, style.join)
end
