ssh-add

set -e # stop on failure; useful for when builds fail we don't try to activate them
# set -x # debugging line
set -o pipefail

# search `# nixos-command` for the actual nixos commands

# Display how to use the script
display_usage() {
    echo "Usage: $0 --system|-s <system-name> [--target|-t <deploy-target>] [--user|-u <ssh-user>]"
    echo "  --system|-s <system-name> : The name of the system to build (required)"
    echo "  --target|-t <deploy-target> : The IP or hostname to deploy to. If not provided, <system-name> will be used."
    echo "  --user|-u <ssh-user> : The SSH user for deployment. If not provided, 'root' will be used."
    exit 1
}


# Exit program
die () {
    echo >&2 "$@"
    exit 1
}

# Initialize variables with default values
export SYSTEM=""  # should this be the current computer?
export DEPLOY_TARGET=""
export SSH_USER="root"


# Display how to use
if [[ $# -eq 0 ]]; then
  echo "Error: No arguments provided. Displaying how to use."
  echo 
  display_usage
  exit 1
fi


# Parse named arguments
while [[ "$#" -gt 0 ]]; do

    case $1 in
        --system|-s) SYSTEM="$2"; shift ;;
        --target|-t) DEPLOY_TARGET="$2"; shift ;;
        --user|-u)   SSH_USER="$2"; shift ;;
        *) echo "Error: Unknown parameter passed: $1" >&2; exit 1 ;;
    esac
    shift
done

# Validate required arguments
[ -z "$SYSTEM" ] && die "The --system argument is required."

# Check if $SYSTEM is empty
if [ -z "$SYSTEM" ]; then
    echo "We should not have gotten here!!!"
    exit 1
fi

# use system for deploy target if deploy target is empty 
if [ -z "$DEPLOY_TARGET" ]; then
  DEPLOY_TARGET=$SYSTEM
fi
 
NIXOS_DEPLOY_VERSION="$(git describe --always --dirty) $(git log -1 --format="%cd" --date=format:%y%m%d\ %I:%M:%S\ %p)"

# renamed dir to nixos-builds since having it as build/$SYSTEM made it harder to autocomplete ./build-and-deploy.sh 
echo "Downloading nixpkgs then building $SYSTEM."
result=$(nix-build -o nixos-builds/$SYSTEM) # can be run manually by setting "export SYSTEM='<systemName>'"
export result # export on another line so that if we ge ta failure it stops right away 
nix-copy-closure --to $SSH_USER@$DEPLOY_TARGET $result
# custom nixos-rebuild-switch script that tries to mimic the `nixos-rebuild switch` command
ssh -t $SSH_USER@$DEPLOY_TARGET $result/nixos-rebuild-switch $USER $NIXOS_DEPLOY_VERSION
echo "Done with the deploy."


