const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const logger = require("firebase-functions/logger");

admin.initializeApp();

// Configuración del transporte SMTP usando Gmail
const transporter = nodemailer.createTransport({
  service: "gmail", // Puedes usar otros servicios SMTP si es necesario
  auth: {
    user: "gavalencia0422@gmail.com", // Tu correo electrónico
    pass: "xvhf kwfb wsra mcsy",
  },
});

// Esta función se activará cuando se haga una solicitud HTTP
exports.sendVerificationEmail = onRequest(async (req, res) => {
  const {email, code} = req.body;

  if (!email || !code) {
    res.status(400).send("Error: Missing email or verification code.");
    return;
  }

  // Configuración del mensaje
  const mailOptions = {
    from: "gavalencia0422@gmail.com",
    to: email,
    subject: "Your verification code",
    text: `Your verification code is: ${code}`,
    html: `<p>Your verification code is: <b>${code}</b></p>`,
  };

  try {
    // Enviar el correo
    await transporter.sendMail(mailOptions);
    logger.info(`Verification email sent to ${email}`);
    res.status(200).send("Email sent successfully");
  } catch (error) {
    logger.error("Error sending email:", error);
    res.status(500).send("Error sending email.");
  }
});
