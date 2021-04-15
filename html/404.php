<?php
include_once('templates/tpl_common.php');
?>

<?php draw_header(["one-page-wonder.css"], ["script.js"]); ?>

<?php draw_landing_nav_bar() ?>

<header class="not-found masthead text-center text-main-color ">
    <div class="masthead-content">
        <section>
            <div class="container info">
                <div class="col-lg-12 order-lg-1">
                    <div class="p-12">
                        <img class="img-fluid" src="images/dolphin.png" width="600" alt="">
                    </div>
                </div>
                <div class="col-lg-12 order-lg-2">
                    <h5 class="display-1">404</h5>
                    <h5>Ups, seems like you wandered into the wrong pond</h5>
                </div>
            </div>
        </section>
    </div>
</header>


<?php draw_landing_footer(); ?>
