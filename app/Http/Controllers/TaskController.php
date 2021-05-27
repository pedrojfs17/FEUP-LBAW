<?php

namespace App\Http\Controllers;

use App\Models\Client;
use App\Models\Comment;
use App\Models\CheckListItem;
use App\Models\Project;
use App\Models\Tag;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
  public function __construct()
  {
    $this->middleware('auth');
  }

  public function list(Request $request, $id)
  {
    $project = Project::find($id);
    $this->authorize('showTasks', $project);

    $tags = $request->input('tag') == NULL ? NULL : explode(',',$request->input('tag'));
    $assignees =$request->input('assignees') == NULL ? NULL : explode(',',$request->input('assignees'));
    $beforeDate = $request->input('before_date');
    $afterDate = $request->input('after_date');

    $tasks = $project->tasks()
      ->when(!empty($tags), function ($query) use ($tags) {
        return $query->whereHas('tags', function ($q) use ($tags) {
          $q->whereIn('tag', $tags);
        });
      })
      ->when(!empty($assignees), function ($query) use ($assignees) {
        return $query->whereHas('assignees', function ($q) use ($assignees) {
          $q->whereIn('client', $assignees);
        });
      })
      ->when(!empty($beforeDate), function ($query) use ($beforeDate) {
        return $query->whereDate('due_date','<=',$beforeDate);
      })
      ->when(!empty($afterDate), function ($query) use ($afterDate) {
        return $query->whereDate('due_date','>=',$afterDate);
      })
      ->get()->sortBy('id');

    $view = view('partials.projectTasks', ['tasks' => $tasks])->render();
    return response()->json($view);
  }

  /**
   * Show the form for creating a new resource.
   *
   * @return \Illuminate\Http\JsonResponse
   */
  public function create(Request $request, $id)
  {
    $request->validate([
      'name' => 'required|string',
      'description' => 'nullable|string',
      'due_date' => 'nullable|date|after:today',
      'parent' => 'nullable|integer'
    ]);

    $task = new Task();
    $task->project = $id;

    $this->authorize('createTask', Project::find($id));

    $task->name = $request->input('name');
    if (!empty($request->input('description')))
      $task->description = $request->input('description');
    if (!empty($request->input('due_date')))
      $task->due_date = $request->input('due_date');
    if (!empty($request->input('parent'))) {
      // TODO - Add task as subtask of parent
    }

    $task->save();

    $result = array(
      'taskCard' => view('partials.tasks.task', ['task' => Task::find($task->id)])->render()
    );

    return response()->json($result);
  }

  /**
   * Display the specified resource.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\JsonResponse
   */
  public function show(Request $request, $id, $task)
  {
    $this->authorize('show', Project::find($id));
    $taskObj = Task::find($task);

    $result = array();

    $result['taskId'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $taskObj])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $taskObj, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }

  /**
   * Update the specified resource in storage.
   *
   * @param \Illuminate\Http\Request $request
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\JsonResponse
   */
  public function update(Request $request, $id, $task)
  {
    $request->validate([
      'name' => 'string',
      'description' => 'string',
      'due_date' => 'date|after:today',
      'task_status' => 'string'
    ]);

    $this->authorize('updateTask', Project::find($id));

    $taskObj = Task::find($task);

    if (!empty($request->input('name')))
      $taskObj->name = $request->input('name');

    if (!empty($request->input('description')))
      $taskObj->description = $request->input('description');

    if (!empty($request->input('due_date')))
      $taskObj->due_date = $request->input('due_date');

    if (!empty($request->input('task_status')))
      $taskObj->task_status = $request->input('task_status');

    $taskObj->save();

    $result = array();
    $result['taskID'] = $taskObj->id;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $taskObj])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $taskObj, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }

  /**
   * Remove the specified resource from storage.
   *
   * @param \App\Models\Task $task
   * @return \Illuminate\Http\JsonResponse
   */
  public function delete(Request $request, $id, $task)
  {
    $this->authorize('deleteTask', Project::find($id));
    $taskObj = Task::find($task);
    $taskObj->delete();
    return response()->json($taskObj);
  }

  public function tag(Request $request, $id, $task)
  {
    //$this->authorize('tag', Project::find($id));
    $request->validate([
      'tag' => 'nullable|string',
    ]);
    Task::find($task)->tags()->detach();

    if(!empty($request->input('tag'))) {
      $tags = array_map('intval',explode(',',$request->input('tag')));
      foreach($tags as $tag) {
        Task::find($task)->tags()->attach($tag);
      }
    }

    $updatedTask = Task::find($task);
    $result = array();
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.tagButton', ['tags' => $updatedTask->tags])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);

  }

  public function subtask(Request $request, $id, $task)
  {
    //$this->authorize('subtask', Project::find($id));
    $request->validate([
      'subtask' => 'nullable|string',
    ]);

    $subTasks = Task::where('parent',$task)->get();
    foreach ($subTasks as $sub) {
      $subtaskObj = Task::find($sub->id);
      $subtaskObj->parent = null;
      $subtaskObj->save();
    }

    if(!empty($request->input('subtask'))) {
      $subtask = array_map('intval', explode(',', $request->input('subtask')));
      foreach ($subtask as $sub) {
        $subtaskObj = Task::find($sub);
        $subtaskObj->parent = $task;
        $subtaskObj->save();
      }
    }

    $updatedTask = Task::find($task);
    $result = array();
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskButton', ['taskArray' => $updatedTask->subtasks])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }

  public function waiting_on(Request $request, $id, $task)
  {
    //$this->authorize('waiting_on', Project::find($id));
    $request->validate([
      'waiting' => 'nullable|string',
    ]);
    Task::find($task)->waitingOn()->detach();

    if(!empty($request->input('waiting'))) {
      $waitingTasks = array_map('intval',explode(',',$request->input('waiting')));
      foreach($waitingTasks as $waiting) {
        Task::find($task)->waitingOn()->attach($waiting);
      }

    }

    $updatedTask = Task::find($task);
    $result = array();
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskButton', ['taskArray' => $updatedTask->waitingOn])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);

  }

  public function assignment(Request $request, $id, $task)
  {
    //$this->authorize('assignment', Project::find($id));
    $request->validate([
      'assign' => 'nullable|string',
    ]);
    Task::find($task)->assignees()->detach();

    if(!empty($request->input('assign'))) {
      $assignees = array_map('intval',explode(',',$request->input('assign')));
      foreach($assignees as $assignee) {
        Task::find($task)->assignees()->attach($assignee);
      }
    }

    $updatedTask = Task::find($task);
    $result = array();
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.clientPhoto', ['assignees' => $updatedTask->assignees])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }

  public function comment(Request $request, $id, $task)
  {
    $comment = new Comment();
    $comment->task = $task;

    //$this->authorize('comment', Project::find($id));

    $comment->author = $request->input('author');
    $comment->comment_date = $request->input('date');
    $comment->comment_text = $request->input('text');

    //Task::find($task)->comments()->attach($comment->id);
    if (!empty($request->input('parent'))) {
      $comment->parent = $request->input('parent');
      $comment->save();

      $result = view('partials.commentReply', ['reply' => Comment::find($comment->id)])->render();
      return response()->json($result);
    }

    $comment->save();
    $result = view('partials.comment', ['comment' => Comment::find($comment->id), 'task' => Task::find($task), 'user' => Client::find(Auth::user()->id)])->render();
    return response()->json($result);
  }

  public function createItem(Request $request, $id, $task)
  {
    //$this->authorize('comment', Project::find($id));
    $request->validate([
      'new_item' => 'required|string'
    ]);

    $item = new CheckListItem();
    $item->task = $task;

    //$this->authorize('createTask', Project::find($id));

    $item->item_text = $request->input('new_item');
    $item->completed = false;
    $item->save();

    $result = array();
    $updatedTask = Task::find($task);
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalChecklist', ['task' => $updatedTask])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }

  public function updateItem(Request $request, $id, $task, $item)
  {
    $request->validate([
      'completed' => 'required|string'
    ]);

    $item = CheckListItem::find($item);

    //$this->authorize('createTask', Project::find($id));

    $item->completed = filter_var($request->input('completed'), FILTER_VALIDATE_BOOLEAN);
    $item->save();

    $updatedTask = Task::find($task);
    $result = array();
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalChecklist', ['task' => $updatedTask])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }

  public function deleteItem(Request $request, $id, $task, $item)
  {
    //$this->authorize('createTask', Project::find($id));
    $item = CheckListItem::find($item);
    $item->delete();

    $updatedTask = Task::find($task);
    $result = array();
    $result['taskID'] = $task;
    $result['taskCard'] = view('partials.tasks.task', ['task' => $updatedTask])->render();
    $result['modalChanges'] = view('partials.tasks.taskModalChecklist', ['task' => $updatedTask])->render();
    $result['taskModal'] = view('partials.tasks.taskModal', ['task' => $updatedTask, 'user' => Client::find(Auth::user()->id)])->render();

    return response()->json($result);
  }
}
