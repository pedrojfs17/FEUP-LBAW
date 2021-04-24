<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class AssociatedProjectAccount extends Model
{
    public $timestamps = false;

    protected $table = 'associated_project_account';

    protected $fillable = [
      'account','project'
    ];

    protected $primaryKey = ['account','project'];

    public function account() {
        return $this->hasOne(SocialMediaAccount::class,'account');
    }

    public function project() {
        return $this->hasOne(Project::class,'project');
    }

}
