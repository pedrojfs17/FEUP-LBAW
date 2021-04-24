<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $table = 'project';

    public $timestamps = false;

    //CURRENT_DATE AND UPDATE_DATE USEFUL?

    protected $fillable = [
      'name','description','due_date',
    ];

    public function teamMember() {
        return $this->hasMany(TeamMember::class,'project_id');
    }

    public function task() {
        return $this->hasMany(Task::class,'project');
    }

    public function tag() {
        return $this->hasMany(Tag::class,'project');
    }

    public function invite() {
        return $this->hasMany(Invite::class,'project_id');
    }
}
