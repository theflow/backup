===CONTRIBUTE===
Contributions are welcome via GitHub! Fork the code from
http://github.com/jashmenn/backupgem/tree/master and send a pull request to jashmenn.

===What is Backup?===
<tt>Backup</tt> is the easiest and most flexible backup, archive and rotate
tool.  It's a beginning-to-end solution for scheduled backups in a clean ruby
package that is simple use and powerful when customized.

Backup allows you to specify each of the following options:
* what is being archived (files, folders, arbitrary scripts)  
* how it's being archived (tar gzip, bz2)
* where the archive is going (multiple backup servers? easy)           
* how the archive is going to get there (scp, ftp, mv)
* where is will be stored when it gets there
* how it's going to be rotated when it gets there (grandfather-father-son, etc)
* how often will this process happen (customizable cycles)
* what happens to the working copy after the process (recreate files, folders etc. restart daemons)

Backup is a collection of scripts that is complete enough to save you
time, but flexible enough to work with any situation.

===Getting Backup===
====Prerequisites====   
Backup makes the following assumptions about your machines:
* server and client understand POSIX commmands
* passwords and paths are the same on each server

Backup depends on the following libraries:
* [[Runt]] for describing [[temporal ranges]]
* [[Net::SSH]] for SSH backups
* [[Net::FTP]] for FTP backups

These are listed as dependencies in the gem file so you should be prompted to
install them when you install Backup.

====Using RubyGems====
If you have [[http://rubygems.rubyforge.org RubyGems]] installed, installing
Backup is simple:

  sudo gem install backupgem

====Using svn====
If you prefer, you can checkout backupgem from the [[RubyForge Repository]].
Feel free to browse the releases or trunk [[here]].

  svn+ssh://blar blar blar

===License Information===
Backup is made available under either the BSD license, or the same license Ruby
(which, by extension, also allows the GPL as a permissable license as well).
You can view the full text of any of these licenses in the <tt>doc</tt> subdirectory
of the Backup distrubtion. The texts of the BSD and GPL licenses are also
available online: "BSD":http://www.opensource.org/licenses/bsd-license.php and
"GPL":http://www.opensource.org/licenses/gpl-license.php.

If you desire permission to use either Backup in a manner incompatible with
these licenses, please contact the copyright holder
([[mailto:nate@natemurray.com Nate Murray]] in order to negotiate a more
compatible license.

===Support===
Mailing lists, bug trackers, feature requests, and public forums are all
available courtesty of [[http://rubyforge.org RubyForge]] at the 
[[http://rubyforge.org/projects/backupgem BackupGem project page]].

====Mailing Lists====
{|class="wikitable"
! List Name
!
! Desc.
|---
| [[http://rubyforge.org/pipermail/backupgem-users backupgem-users]]
| [[http://rubyforge.org/mailman/listinfo/backupgem-users subscribe / unsubscribe]]
| The BackupGem users list is devoted to the discussion of and questions about the usage of Backup. If you can't quite figure out how to get a feature of Backup to work, this is the list you would go to in order to ask your questions. 
|---
| [[http://rubyforge.org/pipermail/backupgem-devel backupgem-devel]]
| [[http://rubyforge.org/mailman/listinfo/backupgem-devel subscribe / unsubscribe]]
| The Backup developers list is devoted to the discussion of Backup's implementation. If you have created a patch that you would like to discuss, or if you would like to discuss a new feature, this is the list for you.
|}

===About the Author===
Backup was written by [[mailto:nate@natemurray.com Nate Murray]. 
Nate currently works at an internet retailer in Southern California.
Feel free to send him compliments, candy, money, praise, or new feature patches--he likes
all those things. You can send him questions and suggestions, too, if you
really want to. However, for bug reports and general feature requests,
please use the trackers on the [[http://rubyforge.org/projects/backupgem BackupGem project page]].

===Special Thanks===
* Matt Pulver for help with various technical problems and ideas.

* Jamis Buck for writing [http://weblog.rubyonrails.com/2006/8/30/capistrano-1-1-9-beta Capistrano]. Capistrano provided the inspiration and some code for this work. Additionally, the Net::SSH manual provided the inspiration for this manual. Thanks for the top-notch work Jamis!

* [[mailto:info@digitalclash.com Matthew Lipper]] for writing the Runt Ruby Temporal Expressions Library

==How Backup Works==
===Intro===
A basic backup has the following sequence:
* content 
* compress 
* encrypt 
* deliver 
* rotate 
* cleanup

This order is the default, however, like most things it is customizable. 
Think of it like a pipline: the input of each step is the output of the last
step.

Each of these things are specified in a <tt>recipe</tt> file which is describe below. 

===CLI===

  Usage: ./backup [options] 
  Recipe Options -----------------------
      -r, --recipe RECIPE              A recipe file to load. Multiple recipes
                                       may be specified, and are loaded in the 
                                       given order.
      -g, --global FILE                Specify the global recipe file to work
                                       with. Defaults to the file <tt>global.rb</tt> 
                                       in the directory of <tt>recipe</tt> 
      -s, --set NAME=VALUE             Specify a variable and it's value to 
                                       set. This will be set after loading all
                                       recipe files.

==Backup Recipe File Format==
===Introduction===
* The Backup Recipe format is pure ruby code. Anything that is valid ruby is valid in the recipe file. There are a number of shortcuts that will make your life easier.

* Each of the steps are specified as an <tt>action</tt>. (An action is really nothing more than a method that becomes defined in the Actor instance. See API docs if you're interestd.)

* You may create "hook" actions for any of the actions. So if you define a method <tt>before_content</tt> it will be called just before <tt>content</tt> is called. A method named <tt>after_rotation</tt> would be called after rotation. This may not always be needed as you can customize the rotation order to be whatever you want. See [[#XXX]] below. 

* Each action has the variable <tt>last_result</tt> available to it. This is the return value of the method that was called previously. Note that this includes the output of the "hook" methods. 

* All configuration variables are available to actions via the hash c[]. For example, the backup path is available to your actions as c[:backup_path].

===Variables===
Intro on how to set variables. How this works.

Required variables for all configurations.
{|class="wikitable"
! Name
! Desc.
! Example
|---
| :action_order
| short desc. TODO 
| set :action_order,      %w{ content compress encrypt deliver rotate cleanup }
|---
| :tmp_dir
| Specify a directory that backup can use as a temporary directory. Default <tt>/tmp</tt>.
| set :tmp_dir, File.dirname(__FILE__) + "/../tmp"
|---
| :backup_path
| The path to backup on. TODO - if its local the local server if its foreign the foreign server
| set :backup_path, "/var/local/backups/mediawiki"
|}

===Content===
The first step in any backup is the content that is to be backed up. Backup
provides a couple of shortcuts for common ways to locate content and allows you
to arbitrarily define your own.

Some typical types of content are:
* a particular file
* a particular folder
* the contents of a particular folder 

These could be specified like so:

  action :content, :is_file   => "/path/to/file"               # content is a single file
  action :content, :is_file   => "/path/to/error_log", :recreate => true
  action :content, :is_folder => "/path/to/folder"             # content is the folder itself 
  action :content, :is_contents_of => "/path/to/other/folder"  # content is folder/* , recursive option

If you want :content to be a series of shell commands just pass "action" a block:

  action(:content) do 
    sh "echo \"hello $HOSTNAME\""
    sh "mysqldump -uroot database > /path/to/db.sql" 
    "/path/to/db.sql" # make sure you return the full path to the folder/file you wish to be the content 
  end

===Compress===
Next you may want to compress your content. Again, there are a few one-liners for common cases and you can create your own.

  action :compress, :method => :tar_bz2  # actually calls a method named tar_bz2 with output of ":content" ( or ":after_content" ) 
  # or
  action :compress, :method => :tar_gzip 

Again, you can create your own.

  action(:compress) 
    sh "my_tar  #{last_result} #{last_result}.tar" 
    sh "my_bzip #{last_result}.tar #{last_result}.tar.bz2"
    last_result + ".tar.bz2"
  end

===Encrypt===
If you wish to use encryption this is available to you. I would recommend that
you think seriously about how you wish to manage your keys for this backup
process. If you are backing up encrypted data then you need to backup your keys
or else you risk losing access to your data. Secure key management is beyond
the scope of this document, but I recommend the following links:
* link 1
* link 2

  set :encrypt, true                              # default is <tt>false</tt>
  set :gpg_encrypt_options, "--default-recipient" # default is an empty string
  action :encrypt, :method => :gpg # default, none

or your own:

  action(:encrypt)
    sh "gpg #{c[:gpg_encrypt_options]} --encrypt #{last_result}"
    last_result + ".gpg" # ?
  end

===Delivery===
====Action====
Delivery is supported via <tt>scp</tt>, <tt>ftp</tt>, and <tt>mv</tt>

  action :deliver, :method => :scp
  action :deliver, :method => :ftp
  action :deliver, :method => :mv

The <tt>:mv</tt> action is defined like any user-defined action:

  action(:mv) do
    sh "mv #{last_result} #{c[:backup_path]}/"
    c[:backup_path] <tt> "/" </tt> File.basename(last_result)
  end

====Variables====
{|class="wikitable"
! Name
! Desc.
! Example
|---
| :servers
| An array of host names to deliver the data to. TODO this currently only supports 1 server. 
| set :servers,           %w{ localhost }
|---
| :ssh_user
| The name of the ssh user on the foreign server. Default ENV['USER'].
| set :ssh_user,          ENV['USER']
|---
| :identity_key
| The path to the key to use when ssh'ing into a foreign server.
| set :identity_key,      ENV['HOME'] + "/.ssh/id_rsa"
|}

==Rotate==
Rotation of your backups is a way to keep snapshot copies of your backups in time while not keeping every single backup for every single day.
Currently the only form of rotation Backup supports is [[grandfather-father-son]] See Appendix A if you are unfamiliar with how this works. 

  set :rotation_method,  :gfs # this is the default. you don't need to set it, but this is how you could

By deafult, a <tt>son</tt> is created daily, unless it is a day to create a father or
grandfather.  It is assumed that every time you run Backup you want to create a
backup. Therefore, if you do not want to a son etc, do not run the program. 
You can specify when the son is promoted to a father by the following variable.

  set :son_promoted_on,    :fri

You specify when fathers are promoted to grandfathers by something like the following

  set :father_promoted_on, :last_fri_of_the_month

Valid argumetns for specifying these promotions are as follows:
* :mon-:sun - A symbol of the abbreviation of any day of the week
* :last_*_of_the_month - A symbol, replacing the * with the abbreviation for the day of the weeks. Such as :last_fri_of_the_month.
* Any valid Runt object. 

Representing these [[temporal ranges]] is done internally by using Runt. You are, therefore, allowed to pass in your own arbitrarily complex runt object.
Say for instance that I wanted to promote to fathers on monday, wednesday and friday. I could do something like the following:

  mon_wed_fri = Runt::DIWeek.new(Runt::Mon) | 
                Runt::DIWeek.new(Runt::Wed) | 
                Runt::DIWeek.new(Runt::Fri)
  set :son_promoted_on, mon_wed_fri

See the [[Runt documentation]] for more information on this.

You can set how many of each rank to keep:

set :sons_to_keep,         14
set :fathers_to_keep,       6
set :grandfathers_to_keep,  6   

==Examples==

Here we will cover three examples. 
# a super-simple backup to a local directory, show how easy it is
# a more complex implementation, show the variables you can set show the customizability and use of foreign server
# every more complex. define your own method, use a global file to share in the configuration.

===Example One: Backup folder of Logs===
Our first example will be backing up a folder of logs. Say we have a folder
'/var/my_logs/' and it is full of log files. It's full. Seriously, it's getting
stuffy in there. 
Anyway, what we want is to:
* move out all the old log files
* compress them and store them in a local folder
* store 2 weeks of daily backups (sons)
* store a weekly backup (father) going back 6 weeks
* and create a monthly backup on the last friday of every month (grandfather) for 6 months

Thankfully, this is incredibly simple:

  set :backup_path, "/var/local/backups/my_old_logs"
  set :tmp_dir, "/tmp" # this is the default so you actually dont have to specify it
  action :content, :is_contents_of => "/var/my_logs"

''In this case, make sure that <tt>:backup_path</tt> and <tt>:tmp_dir</tt> are writable by the user
that is running the backup script.''

And thats it!

Note a few things here.
# Each time we <tt>set</tt> a variable that becomes available to the actions as <tt>c[:var]</tt>

===Example Two: SQL Backup===
Our second example will be backing up a MediaWiki installation. 
Say we have a MySQL database named 'mediawiki'. 
What we want is to:
* create a dump of the database every day
* compress this backup and store it in a local folder
* store 2 weeks of daily backups (son) [same as last time]
* store "father" backups every monday,wednesday and friday going back 6 weeks
* and create a monthly backup on the last friday of every month (grandfather) for 6 months

Thankfully, this is incredibly simple:

  set :backup_path, "/var/local/backups/mediawiki"

  action(:content) do
    dump = c[:tmp_dir] + "/mediawiki.sql"
    sh "mysqldump -uroot mediawiki > #{dump}"
    dump # make sure you return the name of the file
  end

  action :deliver, :method => :scp
  action :rotate,   :method => :via_ssh

  set :servers,           %w{ my.server.com }

  set :son_promoted_on,    :sun
  set :father_promoted_on, :last_sun_of_the_month

  set :sons_to_keep,         21  
  set :fathers_to_keep,      12
  set :grandfathers_to_keep, 12 

===Example Three: Something more complex===

  action :content,  :is_file => "/path/to/file.abc"
  action :compress, :method  => :my_tar_gzip

  action(:my_tar_gzip) do
    name = c[:tmp_dir] + "/" + File.basename(last_result) + ".tar.gzip"
    sh "tar -czv --exclude .DS* --exclude CVS  #{last_result} > #{name}"
    name # make sure you return the name of the
  end

  set :encrypt, true

  action :deliver,  :method => :scp  
  action :rotate,   :method => :via_ssh

  set :ssh_user,          "backup_user"
  set :identity_key,      ENV['HOME'] + "/.ssh/backup_key"

* how to setup the cron job

==TODO==

what is left to do:
* start testing it
* work on the styles
* lookup setup.rb files

==TODO==
* Add in better logging 

==BUGS==
* You can't <tt>return</tt> in the user-defined actions for some reason. I think this
  has to do with the <tt>instance_eval</tt>. But still, I wouldn't think it would
  matter. I'd be interested in any suggestions on how to fix this.
