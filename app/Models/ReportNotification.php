<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class ReportNotification extends Model
{
    public $timestamps = false;

    protected $table = 'report_notification';

    protected $fillable = [
        'report'
    ];

    public function notification() {
        return $this->belongsTo(Notification::class);
    }

    public function report() {
        return $this->hasOne(Report::class,'report');
    }
}
