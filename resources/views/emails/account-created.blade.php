<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->

<p>{{ __('mail.account_greeting', ['name' => $person->full_name]) }}</p>

<p>
    {{ __('mail.account_created_intro', ['app' => config('app.name')]) }}{{ $createdBy ? __('mail.account_created_by', ['createdBy' => $createdBy->full_name]) : '' }}.
</p>

<p>
    <strong>{{ __('mail.log_in_at') }}</strong> <a href="{{ \App\Models\Control\Warehouse::current()->publicUrl('/login') }}">{{ \App\Models\Control\Warehouse::current()->publicUrl('/login') }}</a><br>
    <strong>{{ __('mail.email_label') }}</strong> {{ $person->email }}
</p>

<p>
    {{ __('mail.password_separately') }}
    {{ $createdBy ? $createdBy->full_name : __('mail.your_administrator') }}{{ __('mail.password_separately_tail') }}
    @if ($person->password_change_required)
    {{ __('mail.password_change_required') }}
    @endif
</p>

<p>
    {{ __('mail.forgot_password_intro') }}
    <a href="{{ \App\Models\Control\Warehouse::current()->publicUrl('/forgot-password') }}">{{ __('mail.forgot_password_link') }}</a> {{ __('mail.forgot_password_tail') }}
</p>
