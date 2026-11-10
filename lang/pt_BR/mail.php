<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Outgoing e-mail strings: subjects (app/Mail/*.php + MailSettingsController
// test) and body lines (resources/views/emails/*.blade.php). Values are plain
// text only — blades wrap HTML tags themselves and echo with {{ }}, so
// user data keeps being escaped. Placeholders (:name, :warehouse, ...) are
// filled by the translator and must be preserved.

return [
    // Subjects
    'invitation_subject' => 'Você foi convidado para :warehouse',
    'account_created_subject' => 'Sua conta no :app',
    'form_submission_subject' => 'Nova submissão: :form',
    'feedback_submitted_subject' => ':flagged:urgent[:label] :page',
    'feedback_label_bug' => 'Relatório de bug',
    'feedback_label_feature' => 'Solicitação de funcionalidade',
    'feedback_urgent_prefix' => '[URGENTE] ',
    'feedback_flagged_prefix' => '[SINALIZADO] ',
    'feedback_status_transition_subject' => 'Atualização do seu relatório: :status',
    'feedback_status_comment_subject' => 'Novo comentário no seu relatório',
    'test_subject' => 'E-mail de teste do Relief Inventory',
    'test_body' => "Esta é uma mensagem de teste do Relief Inventory em :url.\n\nSe você consegue ler isto, o envio de e-mail está funcionando.",

    // Feedback status labels (subject + body)
    'feedback_status_new' => 'Novo',
    'feedback_status_seen' => 'Reconhecido',
    'feedback_status_in_development' => 'Em desenvolvimento',
    'feedback_status_resolved' => 'Resolvido',

    // membership-invitation
    'hello' => 'Olá,',
    'administrator_fallback' => 'Um administrador',
    'invitation_join' => ':invitedBy convidou você para participar de',
    'invitation_join_tail' => 'no :app usando seu login existente (:email).',
    'invitation_accept' => 'Nada muda até você aceitar. Para aceitar, abra o link abaixo e informe sua senha:',
    'invitation_expires' => 'O link funciona até :date. Se você não esperava este e-mail, ignore-o: seu login não fica vinculado a',
    'invitation_unless_accepted' => 'a menos que você aceite.',

    // account-created
    'account_greeting' => 'Olá :name,',
    'account_created_intro' => 'Uma conta foi criada para você no :app',
    'account_created_by' => ' por :createdBy',
    'log_in_at' => 'Acesse em:',
    'email_label' => 'E-mail:',
    'password_separately' => 'Sua senha será entregue separadamente por',
    'your_administrator' => 'seu administrador',
    'password_separately_tail' => '; ela não está incluída neste e-mail.',
    'password_change_required' => 'Você deverá escolher sua própria senha no primeiro login.',
    'forgot_password_intro' => 'Se você não receber sua senha, use',
    'forgot_password_link' => 'Esqueceu sua senha?',
    'forgot_password_tail' => 'na página de login para definir uma própria.',

    // form-submission-notification
    'form_submission_intro' => 'Nova submissão para :form',
    'from' => 'de',
    'view_in_ri' => 'Ver no Relief Inventory',

    // feedback-report-submitted
    'urgent' => 'URGENTE',
    'flagged_intro' => '⚠ SINALIZADO:',
    'flagged_body' => 'O texto deste relatório corresponde a um padrão conhecido de injeção de prompt/exfiltração (:reason). Revise com cuidado antes de agir — especialmente antes de deixar um assistente de IA agir sobre ele sem supervisão.',
    'page_label' => 'Página:',
    'message_label' => 'Mensagem:',
    'browser_label' => 'Navegador:',
    'running_commit_label' => 'Commit em execução:',

    // feedback-report-status-updated
    'type_bug' => 'relatório de bug',
    'type_feature' => 'solicitação de funcionalidade',
    'status_transition_body' => 'Seu :type ":message" agora está',
    'status_comment_body' => 'Um novo comentário foi adicionado ao seu :type',
    'currently' => 'atualmente',
    'note_from_developer' => 'Nota do desenvolvedor:',
    'thanks_helping' => 'Obrigado por ajudar a melhorar o Relief Inventory.',
];
