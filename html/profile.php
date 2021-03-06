<?php
    include_once('templates/tpl_common.php');
?>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Oversee</title>
        
        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl" crossorigin="anonymous">
        <!-- Bootstrap Icons -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.0/font/bootstrap-icons.css">

        <link rel="stylesheet" href="css/style.css">
        
        <!-- Bootstrap JavaScript -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/js/bootstrap.bundle.min.js" integrity="sha384-b5kHyXgcpbZJO/tY9Ul7kGkf1S0CWuKcCD38l8YkeH8z8QjE0GmW1gYU5S9FOnJ0" crossorigin="anonymous" defer></script>
        
        <script src="js/profile.js" defer></script>
    </head>
    <body>
        <?php draw_nav_bar() ?>

        <div class="container">
            <div class="row align-items-center mt-5">
                <h1><a class="fs-4 me-4" href="#"><i class="bi bi-chevron-left"></i></a>Profile</h1>
            </div>

            <hr>

            <div class="row justify-content-around mt-5">
                <div class="col-lg-3 col-md-6 col-sm-6 d-flex align-items-center justify-content-center">
                    <img src="images/avatar.png" alt="Avatar" class="img-fluid mx-auto d-block">
                </div>
                <div class="col-lg-4 align-items-center justify-content-center">
                    <form>
                        <label for="usernameInput" class="form-label">Username</label>
                        <div class="input-group mb-3">
                            <input type="text" placeholder="person_mcf" class="form-control" id="usernameInput" disabled>
                            <button class="btn btn-outline-secondary" type="button" id="button-editUsername"><i class="bi bi-pencil"></i></button>
                        </div>

                        <label for="nameInput" class="form-label">Full Name</label>
                        <div class="input-group mb-3">
                            <input type="text" placeholder="Pedro Jorge" class="form-control" id="nameInput" disabled>
                            <button class="btn btn-outline-secondary" type="button" id="button-editName"><i class="bi bi-pencil"></i></button>
                        </div>

                        <label for="emailInput" class="form-label">Email</label>
                        <div class="input-group mb-3">
                            <input type="email" placeholder="pmfriend98@gmail.com" class="form-control" id="emailInput" disabled>
                            <button class="btn btn-outline-secondary" type="button" id="button-editEmail"><i class="bi bi-pencil"></i></button>
                        </div>

                        <label for="companyInput" class="form-label">Company</label>
                        <div class="input-group mb-3">
                            <input type="text" placeholder="" class="form-control" id="companyInput" disabled>
                            <button class="btn btn-outline-secondary" type="button" id="button-editCompany"><i class="bi bi-pencil"></i></button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="row align-items-center mt-5">
                <h4>Change Password</h4>
            </div>

            <hr>

            <div class="row justify-content-center align-items-begin">
                <div class="col-lg-4">
                    <label for="inputPassword6" class="col-form-label">Old Password</label>
                    <input type="password" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
                    <span id="passwordHelpInline" class="form-text">
                        Must be 8-20 characters long.
                    </span>
                </div>
                <div class="col-lg-4">
                    <label for="inputPassword6" class="col-form-label">New Password</label>
                    <input type="password" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
                    <span id="passwordHelpInline" class="form-text">
                        Must be 8-20 characters long.
                    </span>
                </div>
                <div class="col-lg-4">
                    <label for="inputPassword6" class="col-form-label">Repeat New Password</label>
                    <input type="password" id="inputPassword6" class="form-control" aria-describedby="passwordHelpInline">
                    <span id="passwordHelpInline" class="form-text">
                        Must be 8-20 characters long.
                    </span>
                    <div class="d-grid pt-4 gap-2">
                        <button type="button" class="btn btn-dark">Change Password</button>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>