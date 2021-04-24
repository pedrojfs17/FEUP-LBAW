<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class AssignmentNotification extends Model
{
    public $timestamps = false;

    protected $table = 'assignment_notification';

    protected $fillable = [
        'assignment'
    ];

    public function notification() {
        return $this->belongsTo(Notification::class);
    }

    public function assignment() {
        return $this->hasOne(Assignment::class,'assignment');
    }
}
