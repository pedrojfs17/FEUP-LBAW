<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header([], []); ?>

<div class="container d-flex flex-column justify-content-center my-5">
    <div class="row">
        <img src="images/oversee_blue_txt.svg" height="90" alt="company logo"></a>
    </div>

    <div class="row justify-content-center mt-5">
        <div class="col-xl-4 col-lg-5 col-md-7">
            <div class="fs-2">Sign in</div>
            <div class="text-muted fs-5">Good to see you again!</div>
            <div class="text-muted fs-5">New to Oversee? <a href="sign_up.php" class="text-decoration-none" style="color: #00AFB9;">Sign up</a> instead.</div>
        </div>
    </div>

    <div class="row justify-content-center my-4">
        <div class="col-xl-4 col-lg-5 col-md-7">
            <form>
                <div class="mb-3">
                    <label for="inputUsername" class="form-label">Username / Email</label>
                    <input type="text" class="form-control" id="inputUsername">
                </div>
                <div class="mb-3">
                    <label for="inputPassword" class="form-label">Password</label>
                    <input type="password" class="form-control" id="inputPassword">
                </div>
                <div class="d-grid mt-4">
                    <!-- <button type="submit" class="btn btn-danger" style="background-color: #ea4c89;">Sign in</a> -->
                    <a href="dashboard.php" role="button" class="btn btn-danger" style="background-color: #ea4c89;">Sign in</a>
                </div>
            </form>
        </div>
    </div>

    <div class="row justify-content-center my-4">
        <div class="col-xl-4 col-lg-5 col-md-7">
            <div class="d-grid gap-2">
                <a href="#" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-google me-2"></i>Sign in with Google</a>
                <a href="#" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-facebook me-2"></i>Sign in with Facebook</a>
                <a href="#" role="button" class="btn btn-outline-secondary text-start"><i class="bi bi-twitter me-2"></i>Sign in with Twitter</a>
            </div>
        </div>
    </div>
</div>

<?php draw_footer(); ?>
