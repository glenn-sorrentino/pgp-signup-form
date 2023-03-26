$(document).ready(function () {
  $("#signup-form").submit(async function (event) {
    event.preventDefault();
    const email = $("#email").val();

    try {
      const response = await $.ajax({
        url: "/signup",
        method: "POST",
        data: { email: email },
      });

      if (response.message === "Email saved and encrypted successfully.") {
        alert("Your email has been saved successfully!");
      } else {
        alert("An error occurred. Please try again.");
      }
    } catch (error) {
      alert("An error occurred. Please try again.");
    }
  });
});

