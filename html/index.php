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

<!-- Site footer -->
<footer class="site-footer">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-sm-12 col-md-6">
                <img class="d-inline-block align-top" src="images/oversee_blue_txt_only.svg" height="60" alt="">
                <p class="text-justify mt-4">The social media focused project manager.<br>Developed as coursework for LBAW@FEUP 20/21. </p>
            </div>

            <div class="col-xs-6 col-md-3 ms-auto mb-2 mb-lg-0">
                <a class="btn btn-xl btn-outline-primary my-2 my-sm-0 text-decoration-none" href="contacts.php">Contact Us</a>
            </div>
        </div>
        <hr>
    </div>
    <div class="container me-auto">
        <div class="row">
            <div class="col-md-8 col-sm-6 col-xs-12">
                <p class="copyright-text">Copyright &copy; 2021 All Rights Reserved by
                    <a href="#">lbaw2134</a>.
                </p>
            </div>

            <div class="col-md-4 col-sm-6 col-xs-12">
                <ul class="social-icons">
                    <li><a class="facebook" href="#"><i class="fa fa-facebook"></i></a></li>
                    <li><a class="twitter" href="#"><i class="fa fa-twitter"></i></a></li>
                    <li><a class="dribbble" href="#"><i class="fa fa-dribbble"></i></a></li>
                    <li><a class="linkedin" href="#"><i class="fa fa-linkedin"></i></a></li>
                </ul>
            </div>
        </div>
    </div>
</footer>

<?php draw_footer(); ?>