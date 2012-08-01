class Sudo

if Rails.env.development? # only available in dev mode

  def self.count(clazz)
    "#{Util.pluralize(clazz.all.count, clazz.name)} "
  end

  def self.report()
    puts count(RylyzMember)
    puts count(RylyzMemberPresence)
    puts count(RylyzBlogger)
    puts count(RylyzBloggerSite)
    puts count(RylyzBloggerPlan)
  end


  def self.check(sudo_action)  raise "bad_action" unless sudo_action === SUDO_ACTION end

  def self.delete_all_members(sudo_action)
    check(sudo_action)
    puts "Delete #{RylyzMember.all.delete} RylyzMembers"
    puts "Delete #{RylyzMemberPresence.all.delete} RylyzMemberPresences"
  end

  def self.delete_all_bloggers(sudo_action)
    check(sudo_action)
    puts "Deleted #{RylyzBlogger.all.delete} RylyzBloggers"
    puts "Deleted #{RylyzBloggerSite.all.delete} RylyzBloggerSites"
    puts "Deleted #{RylyzBloggerPlan.all.delete} RylyzBloggerPlans"
  end

  # delete credit cards, visitors, sessions, games

end
end