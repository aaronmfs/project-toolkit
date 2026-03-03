import typer

from project_toolkit.core.updater import check_for_update

app = typer.Typer(help="Project Toolkit CLI")

@app.callback(invoke_without_command=True)
def callback(ctx: typer.Context):
    if ctx.invoked_subcommand is None:
        typer.echo("Run 'project --help' for available commands.")

@app.command()
def update():
    """Check for updates and install if available."""
    check_for_update()

def main():
    app()

if __name__ == "__main__":
    main()
