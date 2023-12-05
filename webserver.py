import subprocess
from flask import Flask, render_template, request

app = Flask(__name__)

# Function to execute a Bash script with arguments


def execute_bash_script(name, waittime, email=None):
    try:
        waittime = int(waittime)
    except ValueError:
        # If parsing as int fails, set it to 5
        waittime = 5
    if name == "":
        name = "Unbenannt"
    try:
        # Pass the name, waittime, and email as arguments to bash script
        script_path = "/home/alex/greenscreen.sh"
        command = [script_path, name, str(waittime)]
        print("Email: ", email)
        if email:
            command.append(email)

        subprocess.run(command, check=True, shell=False)
        return "Script executed successfully", 200
    except subprocess.CalledProcessError as e:
        return f"Error executing script: {str(e)}", 500

# Route for the main page


@app.route('/')
def index():
    return render_template('index.html')

# Route to handle form submission and script execution


@app.route('/execute_script', methods=['POST'])
def handle_execute_script():
    if request.method == 'POST':
        name = request.form.get('name')
        waittime = request.form.get('waittime')
        email = request.form.get('email')

        result, status_code = execute_bash_script(name, waittime, email)
        return result, status_code


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
