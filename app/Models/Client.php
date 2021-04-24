<?php


namespace App\Models;


class Client extends Account
{
    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    protected $table = 'client';

    protected $fillable = [
      'fullname','company', 'avatar', 'client_gender',
      'allowNoti', 'inviteNoti', 'assignNoti', 'waitingNoti', 'commentNoti',
      'reportNoti', 'hideCompleted', 'simplifiedTasks', 'color', 'search'
    ];

    public function account() {
        return $this->belongsTo(Account::class);
    }

    public function country() {
        return $this->hasOne(Country::class,'country');
    }
}
