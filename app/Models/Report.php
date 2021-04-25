<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Report extends Model
{
  public $timestamps = false;

  protected $table = 'report';

  protected $fillable = [
    'report_text', 'state', 'reporter', 'reported'
  ];

  public function reporter()
  {
    return $this->belongsTo(Client::class, 'reporter');
  }

  public function reported()
  {
    return $this->belongsTo(Client::class, 'reported');
  }

  public function notifications()
  {
    return $this->hasMany(ReportNotification::class, 'report');
  }
}
