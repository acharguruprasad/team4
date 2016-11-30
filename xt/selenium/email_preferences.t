# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

use 5.14.0;
use strict;
use warnings;

use FindBin qw($RealBin);
use lib "$RealBin/../lib", "$RealBin/../../local/lib/perl5";

use Test::More "no_plan";

use QA::Util;

my ($sel, $config) = get_selenium();

# Used to test sent bugmails
use constant RCPT_BOTH   => 1;
use constant RCPT_ADMIN  => 2;
use constant RCPT_NORMAL => 3;
use constant RCPT_NONE   => 4;
my @email_both = ($config->{admin_user_login}, $config->{editbugs_user_login});
my @email_admin = ($config->{admin_user_login});
my @email_normal = ($config->{editbugs_user_login});
my @email_none = ("no one");

# Test script to test email preferences.
# For reference, following bugmail and request mails should be generated.
#
# Admin should get following bugmails (in order):
#  1) A bug is created
#  2) Normal user adds a CC for itself
#  3) Admin removes CC of normal user
#  4) Admin assigns the bug to itself
#  5) Admin requests a flag from normal user
#  6) Admin grants a flag requested from itself
#  7) Normal user set severity to normal
#  8) Normal user adds a comment #3
#  9) Normal user assigns the bug to itself
# Normal User should get following bugmail (in order):
#  1) A bug is created
#  2) Normal user sets severity to blocker
#  3) Admin sets severity to trivial
#  4) Admin adds a comment #2
#  5) Admin removes CC of normal user
#  6) Admin assigns the bug to itself
#  7) Normal user sets severity to normal
#
# Admin should get following request mails (in order):
#  1) Normal user denies a flag requested by the admin
# Normal user should get following request mails (in order):
#  1) Admin requests a flag from normal user
#
# NOTE that only correct bugmail is verified by the test script because
# sending request mail is not indicated on the UI.

# Set admin Email Prefs (via link in footer)
log_in($sel, $config, 'admin');
$sel->click_ok("link=Preferences");
$sel->wait_for_page_to_load_ok(WAIT_TIME);
$sel->title_is("General Preferences");
$sel->click_ok("link=Email Notifications");
$sel->wait_for_page_to_load_ok(WAIT_TIME);
$sel->is_text_present_ok("Email Notifications");
$sel->click_ok("//input[\@value='Disable All Mail']");
$sel->click_ok("email-0-1", undef, 'Set "I\'m added to or removed from this capacity" for Assignee role');
$sel->click_ok("email-0-5", undef, 'Set "The priority, status, severity, or milestone changes" for Assignee role');
$sel->click_ok("email-0-2", undef, 'Set "New comments are added" for Assignee role');
$sel->click_ok("email-0-0", undef, 'Set "Any field not mentioned above changes" for Assignee role');
$sel->click_ok("email-3-8", undef, 'Set "The CC field changes" for CCed role');
$sel->click_ok("email-1-10", undef, 'Set "A new bug is created" for QA Contact role');
$sel->click_ok("email-100-101", undef, 'Set "Email me when someone sets a flag I asked for" global option');
# Restore the old 4.2 behavior for 'Disable All Mail'.
foreach my $col (0..3) {
    foreach my $row (50..51) {
        $sel->click_ok("neg-email-$col-$row");
    }
}
$sel->value_is("email-0-1", "on");
$sel->value_is("email-0-10", "off");
$sel->value_is("email-0-6", "off");
$sel->value_is("email-0-5", "on");
$sel->value_is("email-0-2", "on");
$sel->value_is("email-0-3", "off");
$sel->value_is("email-0-4", "off");
$sel->value_is("email-0-7", "off");
$sel->value_is("email-0-8", "off");
$sel->value_is("email-0-9", "off");
$sel->value_is("email-0-0", "on");
$sel->value_is("neg-email-0-50", "off");
$sel->value_is("neg-email-0-51", "off");
$sel->value_is("email-1-1", "off");
$sel->value_is("email-1-10", "on");
$sel->value_is("email-1-6", "off");
$sel->value_is("email-1-5", "off");
$sel->value_is("email-1-2", "off");
$sel->value_is("email-1-3", "off");
$sel->value_is("email-1-4", "off");
$sel->value_is("email-1-7", "off");
$sel->value_is("email-1-8", "off");
$sel->value_is("email-1-9", "off");
$sel->value_is("email-1-0", "off");
$sel->value_is("neg-email-1-50", "off");
$sel->value_is("neg-email-1-51", "off");
ok(!$sel->is_editable("email-2-1"), 'The "I\'m added to or removed from this capacity" for Reporter role is disabled');
$sel->value_is("email-2-10", "off");
$sel->value_is("email-2-6", "off");
$sel->value_is("email-2-5", "off");
$sel->value_is("email-2-2", "off");
$sel->value_is("email-2-3", "off");
$sel->value_is("email-2-4", "off");
$sel->value_is("email-2-7", "off");
$sel->value_is("email-2-8", "off");
$sel->value_is("email-2-9", "off");
$sel->value_is("email-2-0", "off");
$sel->value_is("neg-email-2-50", "off");
$sel->value_is("neg-email-2-51", "off");
$sel->value_is("email-3-1", "off");
$sel->value_is("email-3-10", "off");
$sel->value_is("email-3-6", "off");
$sel->value_is("email-3-5", "off");
$sel->value_is("email-3-2", "off");
$sel->value_is("email-3-3", "off");
$sel->value_is("email-3-4", "off");
$sel->value_is("email-3-7", "off");
$sel->value_is("email-3-8", "on");
$sel->value_is("email-3-9", "off");
$sel->value_is("email-3-0", "off");
$sel->value_is("neg-email-3-50", "off");
$sel->value_is("neg-email-3-51", "off");
$sel->value_is("email-100-100", "off");
$sel->value_is("email-100-101", "on");
$sel->click_ok("update", undef, "Submit modified admin email preferences");
$sel->wait_for_page_to_load_ok(WAIT_TIME);
$sel->is_text_present_ok("The changes to your email notifications have been saved.");

# Set "After changing a bug" default preference to "Show the updated bug"
# This simplifies bug changes below
go_to_admin($sel);
$sel->click_ok("link=Default Preferences");
$sel->wait_for_page_to_load(WAIT_TIME);
$sel->title_is("Default Preferences");
$sel->select_ok("post_bug_submit_action", "label=Show the updated bug");
$sel->click_ok("update");
$sel->wait_for_page_to_load(WAIT_TIME);
$sel->title_is("Default Preferences");

# Set normal user Email Prefs
logout($sel);
log_in($sel, $config, 'editbugs');
$sel->click_ok("link=Preferences");
$sel->wait_for_page_to_load(WAIT_TIME);
$sel->title_is("General Preferences");
$sel->click_ok("link=Email Notifications");
$sel->wait_for_page_to_load(WAIT_TIME);
$sel->title_is("Email Notifications");
$sel->is_text_present_ok("Email Notifications");
$sel->click_ok("//input[\@value='Enable All Mail']");
$sel->click_ok("email-3-1", undef, 'Clear "I\'m added to or removed from this capacity" for CCed role');
$sel->click_ok("email-3-5", undef, 'Clear "The priority, status, severity, or milestone changes" for CCed role');
$sel->click_ok("email-2-2", undef, 'Clear "New comments are added" for Reporter role');
$sel->click_ok("email-3-2", undef, 'Clear "New comments are added" for CCed role');
$sel->click_ok("email-2-8", undef, 'Clear "The CC field changes" for Reporter role');
$sel->click_ok("email-3-8", undef, 'Clear "The CC field changes" for CCed role');
$sel->click_ok("email-2-0", undef, 'Clear "Any field not mentioned above changes" for Reporter role');
$sel->click_ok("email-3-0", undef, 'Clear "Any field not mentioned above changes" for CCed role');
$sel->click_ok("neg-email-0-51", undef, 'Set "Change was made by me" override for Assignee role');
$sel->click_ok("email-100-101", undef, 'Clear "Email me when someone sets a flag I asked for" global option');
$sel->value_is("email-0-1", "on");
$sel->value_is("email-0-10", "on");
$sel->value_is("email-0-6", "on");
$sel->value_is("email-0-5", "on");
$sel->value_is("email-0-2", "on");
$sel->value_is("email-0-3", "on");
$sel->value_is("email-0-4", "on");
$sel->value_is("email-0-7", "on");
$sel->value_is("email-0-8", "on");
$sel->value_is("email-0-9", "on");
$sel->value_is("email-0-0", "on");
$sel->value_is("neg-email-0-50", "off");
$sel->value_is("neg-email-0-51", "on");
$sel->value_is("email-1-1", "on");
$sel->value_is("email-1-10", "on");
$sel->value_is("email-1-6", "on");
$sel->value_is("email-1-5", "on");
$sel->value_is("email-1-2", "on");
$sel->value_is("email-1-3", "on");
$sel->value_is("email-1-4", "on");
$sel->value_is("email-1-7", "on");
$sel->value_is("email-1-8", "on");
$sel->value_is("email-1-9", "on");
$sel->value_is("email-1-0", "on");
$sel->value_is("neg-email-1-50", "off");
$sel->value_is("neg-email-1-51", "off");
ok(!$sel->is_editable("email-2-1"), 'The "I\'m added to or removed from this capacity" for Reporter role is disabled');
$sel->value_is("email-2-10", "on");
$sel->value_is("email-2-6", "on");
$sel->value_is("email-2-5", "on");
$sel->value_is("email-2-2", "off");
$sel->value_is("email-2-3", "on");
$sel->value_is("email-2-4", "on");
$sel->value_is("email-2-7", "on");
$sel->value_is("email-2-8", "off");
$sel->value_is("email-2-9", "on");
$sel->value_is("email-2-0", "off");
$sel->value_is("neg-email-2-50", "off");
$sel->value_is("neg-email-2-51", "off");
$sel->value_is("email-3-1", "off");
$sel->value_is("email-3-10", "on");
$sel->value_is("email-3-6", "on");
$sel->value_is("email-3-5", "off");
$sel->value_is("email-3-2", "off");
$sel->value_is("email-3-3", "on");
$sel->value_is("email-3-4", "on");
$sel->value_is("email-3-7", "on");
$sel->value_is("email-3-8", "off");
$sel->value_is("email-3-9", "on");
$sel->value_is("email-3-0", "off");
$sel->value_is("neg-email-3-50", "off");
$sel->value_is("neg-email-3-51", "off");
$sel->value_is("email-100-100", "on");
$sel->value_is("email-100-101", "off");
$sel->click_ok("update", undef, "Submit modified normal user email preferences");
$sel->wait_for_page_to_load_ok(WAIT_TIME);
$sel->is_text_present_ok("The changes to your email notifications have been saved.");

# Create a test bug (bugmail to both normal user and admin)
file_bug_in_product($sel, "Another Product");
$sel->select_ok("component", "label=c1");
my $bug_summary = "Selenium Email Preference test bug";
$sel->type_ok("short_desc", $bug_summary, "Enter bug summary");
$sel->type_ok("comment", "Created by Selenium to test Email Notifications", "Enter bug description");
$sel->type_ok("assigned_to", $config->{editbugs_user_login});
$sel->type_ok("qa_contact", $config->{admin_user_login});
$sel->type_ok("cc", $config->{admin_user_login});
my $bug1_id = create_bug($sel, $bug_summary);
verify_bugmail_recipients($sel, RCPT_BOTH);

# Make normal user changes (first pass)
#
go_to_bug($sel, $bug1_id);
# Severity change (bugmail to normal user but not admin)
$sel->select_ok("bug_severity", "label=blocker");
$sel->selected_label_is("bug_severity", "blocker");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NORMAL);
# Add a comment (bugmail to no one)
$sel->type_ok("comment", "This is a Selenium generated normal user test comment 1 of 2. (No bugmail should be generated for this.)");
$sel->value_is("comment", "This is a Selenium generated normal user test comment 1 of 2. (No bugmail should be generated for this.)");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NONE);
# Add normal user to CC list (bugmail to admin but not normal user)
$sel->type_ok("newcc", $config->{editbugs_user_login});
$sel->value_is("newcc", $config->{editbugs_user_login});
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_ADMIN);
# Request a flag from admin (bugmail to no one, request mail to no one)
$sel->select_ok("flag_type-1", "label=?");
$sel->type_ok("requestee_type-1", $config->{admin_user_login});
$sel->value_is("requestee_type-1", $config->{admin_user_login});
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NONE);

# Make admin changes
#
logout($sel);
log_in($sel, $config, 'admin');
go_to_bug($sel, $bug1_id);
# Severity change (bugmail to normal user but not admin)
$sel->select_ok("bug_severity", "label=trivial");
$sel->selected_label_is("bug_severity", "trivial");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NORMAL);
# Add a comment (bugmail to normal user but not admin)
$sel->type_ok("comment", "This is a Selenium generated admin user test comment. (Only normal user should get bugmail for this.)");
$sel->value_is("comment", "This is a Selenium generated admin user test comment. (Only normal user should get bugmail for this.)");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NORMAL);
# Remove normal user from CC list (bugmail to both normal user and admin)
$sel->click_ok("removecc");
$sel->add_selection_ok("cc", "label=$config->{editbugs_user_login}");
$sel->value_is("removecc", "on");
$sel->selected_label_is("cc", $config->{editbugs_user_login});
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_BOTH);
# Reassign bug to admin user (bugmail to both normal user and admin)
$sel->type_ok("assigned_to", $config->{admin_user_login});
$sel->value_is("assigned_to", $config->{admin_user_login});
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_BOTH);
# Request a flag from normal user (bugmail to admin but not normal user and request mail to admin)
$sel->select_ok("flag_type-1", "label=?");
$sel->type_ok("requestee_type-1", $config->{editbugs_user_login});
$sel->value_is("requestee_type-1", $config->{editbugs_user_login});
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_ADMIN);
# Grant a normal user flag request (bugmail to admin but not normal user and request mail to no one)
my $flag1_id = set_flag($sel, $config->{admin_user_login}, "?", "+");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_ADMIN);

# Make normal user changes (second pass)
#
logout($sel);
log_in($sel, $config, 'editbugs');
go_to_bug($sel, $bug1_id);
# Severity change (bugmail to both admin and normal user)
$sel->select_ok("bug_severity", "label=normal");
$sel->selected_label_is("bug_severity", "normal");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_BOTH);
# Add a comment (bugmail to admin but not normal user)
$sel->type_ok("comment", "This is a Selenium generated normal user test comment 2 of 2. (Only admin should get bugmail for this.)");
$sel->value_is("comment", "This is a Selenium generated normal user test comment 2 of 2. (Only admin should get bugmail for this.)");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_ADMIN);
# Reassign to normal user (bugmail to admin but not normal user)
$sel->type_ok("assigned_to", $config->{editbugs_user_login});
$sel->value_is("assigned_to", $config->{editbugs_user_login});
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_ADMIN);
# Deny a flag requested by admin (bugmail to no one and request mail to admin)
my $flag2_id = set_flag($sel, $config->{editbugs_user_login}, "?", "-");
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NONE);
# Cancel both flags (bugmail and request mail to no one)
set_flag($sel, undef, "+", "X", $flag1_id);
set_flag($sel, undef, "-", "X", $flag2_id);
edit_bug($sel, $bug1_id, $bug_summary);
verify_bugmail_recipients($sel, RCPT_NONE);
logout($sel);

# Set "After changing a bug" default preference back to "Do Nothing".
log_in($sel, $config, 'admin');
go_to_admin($sel);
$sel->click_ok("link=Default Preferences");
$sel->wait_for_page_to_load(WAIT_TIME);
$sel->title_is("Default Preferences");
$sel->select_ok("post_bug_submit_action", "label=Do Nothing");
$sel->click_ok("update");
$sel->wait_for_page_to_load(WAIT_TIME);
$sel->title_is("Default Preferences");
logout($sel);

# Help functions
sub verify_bugmail_recipients {
    my ($sel, $rcpt_sentto) = @_;
    my $wanted_sentto;
    my $err = 0;

    # Verify sentto field
    my @email_sentto
        = sort split(/, /, $sel->get_text("//dt[text()='Email sent to:']/following-sibling::dd"));
    if ($rcpt_sentto == RCPT_BOTH) {
      $wanted_sentto = \@email_both;
      is_deeply(\@email_sentto, $wanted_sentto, "Bugmail sent to both")
          or $err = 1;
    }
    elsif ($rcpt_sentto == RCPT_ADMIN) {
      $wanted_sentto = \@email_admin;
      is_deeply(\@email_sentto, $wanted_sentto, "Bugmail sent to admin")
          or $err = 1;
    }
    elsif ($rcpt_sentto == RCPT_NORMAL) {
      $wanted_sentto = \@email_normal;
      is_deeply(\@email_sentto, $wanted_sentto, "Bugmail sent to normal user")
          or $err = 1;
    } else {
      $wanted_sentto = \@email_none;
      is_deeply(\@email_sentto, $wanted_sentto, "Bugmail sent to no one")
          or $err = 1;
    }

    # In case of an error, retrieve and show diagnostics info
    if ($err) {
        diag("Sent, actual     : " . join(', ', @email_sentto));
        diag("Sent, wanted     : " . join(', ', @$wanted_sentto));
        diag("Changer          : " . trim($sel->get_text('//a[contains(@href, "logout")]/../text()[3]')));
        diag("Reporter         : " . $sel->get_attribute('//th[contains(text(), "Reported:")]/following-sibling::td//a@title'));
        diag("Assignee         : " . $sel->get_value('assigned_to'));
        diag("QA contact       : " . $sel->get_value('qa_contact'));
        diag("CC List          : " . join(', ', $sel->get_select_options('cc')));
    }
}

sub set_flag {
    my ($sel, $login, $curval, $newval, $prev_id) = @_;

    # Retrieve flag id for the flag to be set
    my $flag_id = $prev_id;
    if (defined $login) {
        my $flag_name = $sel->get_attribute("//table[\@id='flags']//input[\@value='$login']\@name");
        $flag_name =~ /^requestee-(\d+)$/;
        $flag_id = $1;
    }

    # Set new value for the flag (verifies current value)
    $sel->select_ok("//select[\@id=\"flag-$flag_id\"]/option[\@value=\"$curval\" and \@selected]/..", "value=$newval", "Set flag ID $flag_id to $newval from $curval");

   return $flag_id;
}
