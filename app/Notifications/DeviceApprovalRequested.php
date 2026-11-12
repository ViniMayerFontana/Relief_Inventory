<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Notifications;

use App\Models\TrustedDevice;
use Illuminate\Notifications\Notification;

/**
 * In-app bell alert to manage-trusted-devices holders: someone asked for PIN login on a device
 * (ThisDeviceController). Database-only, like KioskCheckInAlert; the bell shows category_label — name.
 */
class DeviceApprovalRequested extends Notification
{
    public function __construct(private readonly TrustedDevice $device) {}

    /**
     * @return array<int, string>
     */
    public function via($notifiable): array
    {
        return ['database'];
    }

    /**
     * @return array<string, mixed>
     */
    public function toDatabase($notifiable): array
    {
        $this->device->loadMissing('requester');
        $what = $this->device->label ?: trim(($this->device->browser ?? trans('notifications.a_browser')).' '.trans('notifications.on').' '.($this->device->os ?? trans('notifications.an_unknown_system')));

        return [
            'kind' => 'device_approval_requested',
            'trusted_device_id' => $this->device->id,
            'category_label' => trans('notifications.category_label_pin_login'),
            'name' => $what.' — '.($this->device->requester?->full_name ?? trans('notifications.someone')),
            'url' => '/setup/pin-login',
        ];
    }
}
