<?php

namespace App\Http\Controllers;

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
   * @return \Illuminate\Http\JsonResponse
   */
  public function list()
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

    return response()->json($results);
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
   * @return \Illuminate\Http\JsonResponse
   */
  public function delete(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('delete', $project);
    $project->delete();
    return response()->json($project);
  }

  /**
   * Display the specified resource.
   *
   * @param \Illuminate\Http\Request $request
   * @param int $id
   * @return \Illuminate\Contracts\Foundation\Application|\Illuminate\Http\RedirectResponse|Response|\Illuminate\Routing\Redirector
   */
  public function leave(Request $request, $id)
  {
    $project = Project::find($id);

    $this->authorize('leave', $project);

    $team_member = $project->teamMembers()::find(Auth::user()->id);
    $team_member->delete();

    return redirect('pages.dashboard');
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
    $this->authorize('preferences', $project);
    return view('pages.preferences', ['project' => $project, 'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role]);
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
    $this->authorize('assignments', $project);
    return view('pages.assignments', ['assignments' => $project->assignments(), 'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role]);
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
    $this->authorize('status_board', $project);
    return view('pages.status_board', ['status_board' => $project->tasks(), 'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role]);
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
    $this->authorize('statistics', $project);
    return view('pages.statistics', ['project' => $project, 'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role]);
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
    //if ($project == null) return redirect('404');
    $this->authorize('overview', $project);
    return view('pages.overview', ['tasks' => $project->tasks()->get(), 'project' => $project, 'role' => $project->teamMembers()->where('client_id', Auth::user()->id)->first()->pivot->member_role]);
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
