<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * The policy mappings for the application.
     *
     * @var array
     */
    protected $policies = [
      'App\Models\Client' => 'App\Policies\ClientPolicy',
      'App\Models\Project' => 'App\Policies\ProjectPolicy',
      'App\Models\SocialMediaAccount' => 'App\Policies\SocialMediaAccountPolicy',
      'App\Models\Tag' => 'App\Policies\TagPolicy',
      'App\Models\Task' => 'App\Policies\TaskPolicy'
    ];

    /**
     * Register any authentication / authorization services.
     *
     * @return void
     */
    public function boot()
    {
        $this->registerPolicies();
    }
}
