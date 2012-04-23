# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Clean RylyzBlogger
RylyzBlogger.all.destroy
RylyzBloggerSite.all.destroy
RylyzBloggerPlan.all.destroy

puts "Cleaning success..."

# Populate
blogger = RylyzBlogger.create!({ email: 'mike@test.com', invite_code: '1234'})
blogger.create_plan({description: 'Basic Plan 100'})
blogger.sites.create!({url: 'http://myblog.com'})
blogger.sites.create!({url: 'http://myblog2.com'})

puts "Seeding success..."