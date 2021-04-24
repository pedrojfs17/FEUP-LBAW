<?php


namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class UserSupport extends Model
{
    public $timestamps=false;

    protected $table='user_support';

    protected $fillable =[
      'email', 'name','subject','body', 'responded','response'
    ];


}
