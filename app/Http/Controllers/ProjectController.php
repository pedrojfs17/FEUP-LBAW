<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Client;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class ProjectController extends Controller
{

  public function __construct()
  {
    $this->middleware('auth');
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\RedirectResponse|\Illuminate\Routing\Redirector
   */
  public function create(Request $request)
  {
    $request->validate([
      'name' => 'required|string',
      'description' => 'required|string',
      'due_date' => 'date|after:today'
    ]);

    $project = new Project();
    $project->name = $request->input('name');
    $project->description = $request->input('description');
    if (!empty($request->input('due_date')))
      $project->due_date = $request->input('due_date');
    $project->save();

    $project->teamMembers()->attach(Auth::User()->id, ['member_role' => 'Owner']);

    return redirect(route('project.overview', ['id' => $project->id]));
  }

  /**
   * Display the specified resource.
   *
   * @param int $id
   * @param \Illuminate\Http\Request $request
   * @return \Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('show', $project);
    return response()->json($project);
  }

  /**
   * Display the specified resource.
   *
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|\Illuminate\Http\JsonResponse
   */
  public function list(Request $request)
  {
    $results = DB::select("
        SELECT projects.*, round(avg((task_status = 'Completed')::int) * 100) AS completion
        FROM (
            SELECT project.*
            FROM project JOIN team_member ON project.id = team_member.project_id
            WHERE team_member.client_id = :client_id
        ) AS projects LEFT JOIN task ON projects.id = task.project
        GROUP BY projects.id,
            projects.name,
            projects.description,
            projects.due_date,
            projects.search
        ORDER BY projects.id DESC;
      ",
      ['client_id' => Auth::user()->id]
    );

    if ($request->wantsJson())
    {
      return response()->json($results);
    }

    return view('partials.myProjects', ['projects' => Client::find(Auth::user()->id)->projects()]);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $id)
  {
    $request->validate([
      'name' => 'string',
      'description' => 'string',
      'due_date' => 'date|after:today'
    ]);

    $project = Project::find($id);
    $this->authorize('update', $project);

    if (!empty($request->input('name')))
      $project->name = $request->input('name');

    if (!empty($request->input('description')))
      $project->description = $request->input('description');

    if (!empty($request->input('due_date')))
      $project->due_date = $request->input('due_date');

    $project->save();

    return response()->json($project);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Project $project
   * @return
   */
  public function delete(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('delete', $project);
    $project->teamMembers()->wherePivot('member_role', '!=', 'Owner')->detach();
    $project->delete();
    return redirect('dashboard')->with('message', 'Successfully deleted project: ' . $project->name);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Http\JsonResponse|\Illuminate\Http\RedirectResponse|\Illuminate\Routing\Redirector
   */
  public function leave(Request $request, $id, $username)
  {
    $project = Project::find($id);
    $account = Account::where('username', '=', $username);

    $this->authorize('leave', $project, $account);

    $member = $project->teamMembers()->wherePivot('client_id', '=', $account->id);
    $member->detach();

    if (Auth::user()->id == $account->id)
      return redirect('pages.dashboard');
    else
      return response()->json($member);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function preferences(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('preferences', $project);
    return view('pages.preferences', [
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function assignments(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('assignments', $project);
    return view('pages.assignments', [
      'tasks' => $project->tasks()->get(),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function status(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('status_board', $project);
    return view('pages.status_board', [
      'tasks' => $project->tasks()->get(),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id),
      'status_enum' => ["Not Started", 'Waiting', "In Progress", "Completed"]
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function statistics(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('statistics', $project);
    return view('pages.statistics', [
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function overview(Request $request, $id)
  {
    $project = Project::find($id);
    if ($project == null) return view('errors.404');
    $this->authorize('overview', $project);
    return view('pages.overview', [
      'tasks' => $project->tasks()->get(),
      'project' => $project,
      'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role,
      'user' => Client::find(Auth::user()->id)
    ]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function invite(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('invite', $project);
    $project->invites()->attach($request->client);
    return view('pages.overview', ['overview' => $project->tasks()]);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Contracts\View\Factory|\Illuminate\Contracts\View\View|Response
   */
  public function updateInvite(Request $request, $id, $invite_id)
  {
    $project = Project::find($id);
    $request->validate([
      'decision' => 'required|boolean',
    ]);
    $this->authorize('updateInvite', $project);
    $project->invites()->updateExistingPivot($invite_id, [
      'decision' => $request->decision
    ]);
    return view('pages.overview', ['overview' => $project->tasks()]);
  }
}
