<?php
    include_once('templates/tpl_common.php');
?>

<?php draw_header(["one-page-wonder.css"], ["script.js"]); ?>

<?php draw_landing_nav_bar() ?>

<!-- Header -->
<header class="masthead text-center text-white">
    <div class="masthead-content">
        <div class="container">
            <h1 class="masthead-heading mb-5">Social media has never been this easy!</h1>
            <h2 class="masthead-subheading mb-0">Oversee is here to make you reach new heights</h2>
            <a href="dashboard.php" class="btn btn-primary btn-xl rounded-pill mt-5 mx-3">Join Oversee</a>
            <a class="btn btn-primary btn-xl rounded-pill mt-5" id="learnMore" href="#aboutPage">Learn More</a>
        </div>
    </div>
    <div class="bg-circle-1 bg-circle"></div>
    <div class="bg-circle-2 bg-circle"></div>
    <div class="bg-circle-3 bg-circle"></div>
    <div class="bg-circle-4 bg-circle"></div>
</header>

<section id="aboutPage">
    <section>
        <div class="container info">
            <div class="row align-items-center">
                <div class="col-lg-6 order-xl-1">
                    <div class="p-5">
                        <h2 class="display-4">Organize yourself</h2>
                        <p>Plan your social media effectively</p>
                    </div>
                </div>
                <div class="col-lg-6 order-lg-2">
                    <div class="p-5">
                        <img class="img-fluid rounded-circle" src="images/01.jpg" alt="">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section>
        <div class="container info">
            <div class="row align-items-center">
                <div class="col-lg-6 order-xl-2">
                    <div class="p-5">
                        <h2 class="display-4">Improve Yourself</h2>
                        <p>See how your social media is performing with our statistic tools</p>
                    </div>
                </div>
                <div class="col-lg-6 order-lg-1">
                    <div class="p-5">
                        <img class="img-fluid rounded" src="images/02.jpg" alt="">
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section>
        <div class="container info">
            <div class="row align-items-center">
                <div class="col-lg-6 order-lg-1">
                    <div class="p-5">
                        <h2 class="display-4">Go solo or go big</h2>
                        <p>Designed for big teams and individual creators</p>
                    </div>
                </div>
                <div class="col-lg-6 order-lg-2">
                    <div class="p-5">
                        <img class="img-fluid rounded" src="images/03.jpg" alt="">
                    </div>
                </div>
            </div>
        </div>
    </section>
</section>

<?php draw_landing_footer(); ?>