<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// English mirror of lang/pt_BR/mail.php (subjects + body lines). Values are
// plain text only; blades wrap HTML tags themselves.

return [
    // Subjects
    'invitation_subject' => "You're invited to :warehouse",
    'account_created_subject' => 'Your :app account',
    'form_submission_subject' => 'New submission: :form',
    'feedback_submitted_subject' => ':flagged:urgent[:label] :page',
    'feedback_label_bug' => 'Bug Report',
    'feedback_label_feature' => 'Feature Request',
    'feedback_urgent_prefix' => '[URGENT] ',
    'feedback_flagged_prefix' => '[FLAGGED] ',
    'feedback_status_transition_subject' => 'Update on your report: :status',
    'feedback_status_comment_subject' => 'New comment on your report',
    'test_subject' => 'Relief Inventory test email',
    'test_body' => "This is a test message from Relief Inventory at :url.\n\nIf you can read this, outgoing email is working.",

    // Feedback status labels (subject + body)
    'feedback_status_new' => 'New',
    'feedback_status_seen' => 'Acknowledged',
    'feedback_status_in_development' => 'In Development',
    'feedback_status_resolved' => 'Resolved',

    // membership-invitation
    'hello' => 'Hello,',
    'administrator_fallback' => 'An administrator',
    'invitation_join' => ':invitedBy has invited you to join',
    'invitation_join_tail' => 'on :app using your existing login (:email).',
    'invitation_accept' => 'Nothing changes until you accept. To accept, open the link below and enter your password:',
    'invitation_expires' => 'The link works until :date. If you were not expecting this, ignore this email: your login is not attached to',
    'invitation_unless_accepted' => 'unless you accept.',

    // account-created
    'account_greeting' => 'Hi :name,',
    'account_created_intro' => 'An account has been created for you on :app',
    'account_created_by' => ' by :createdBy',
    'log_in_at' => 'Log in at:',
    'email_label' => 'Email:',
    'password_separately' => 'Your password will be given to you separately by',
    'your_administrator' => 'your administrator',
    'password_separately_tail' => '; it is not included in this email.',
    'password_change_required' => "You'll be asked to choose your own password the first time you log in.",
    'forgot_password_intro' => 'If you never receive your password, use',
    'forgot_password_link' => 'Forgot your password?',
    'forgot_password_tail' => 'on the login page to set one of your own.',

    // form-submission-notification
    'form_submission_intro' => 'New submission for :form',
    'from' => 'from',
    'view_in_ri' => 'View in Relief Inventory',

    // feedback-report-submitted
    'urgent' => 'URGENT',
    'flagged_intro' => '⚠ FLAGGED:',
    'flagged_body' => "This report's text matched a known prompt-injection/exfiltration pattern (:reason). Review carefully before acting on it — especially before letting an AI assistant act on it unsupervised.",
    'page_label' => 'Page:',
    'message_label' => 'Message:',
    'browser_label' => 'Browser:',
    'running_commit_label' => 'Running commit:',

    // feedback-report-status-updated
    'type_bug' => 'bug report',
    'type_feature' => 'feature request',
    'status_transition_body' => 'Your :type ":message" is now',
    'status_comment_body' => 'A new comment was added to your :type',
    'currently' => 'currently',
    'note_from_developer' => 'Note from the developer:',
    'thanks_helping' => 'Thanks for helping improve Relief Inventory.',
];
