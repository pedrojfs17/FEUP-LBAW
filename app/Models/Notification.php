<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    public $timestamps = false;

    protected $table = 'notification';

    protected $fillable = [
        'client','seen','notification_date','notification_text'
    ];

    public function client() {
        return $this->belongsTo(Client::class,'client');
    }
}
