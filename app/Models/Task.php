<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    public $timestamps=false;

    protected $table='task';

    protected $fillable = [
      'project','name','description','due_date','task_status','search'
    ];

    public function project() {
        return $this->belongsTo(Project::class,'project');
    }
    public function subtask() {
        return $this->hasMany(Subtask::class,'parent');
    }

}
