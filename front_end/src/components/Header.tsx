
import { useEthers } from "@usedapp/core";
import { Button, makeStyles } from "@material-ui/core";
import { classicNameResolver } from "typescript";

const useStyles = makeStyles(theme => ({
    container: {
        padding: theme.spacing(4),
        display: "flex",
        justifyContent: "felx-end",
        gap: theme.spacing(1),
    }
}))

export const Header = () => {

    const classes = useStyles();
    const { account, activateBrowserWallet, deactivate } = useEthers();

    const isConnected = account !== undefined;


    return (
        <div className={classes.container}>
            {isConnected ? (
                <button color="primary" onClick={() => deactivate()}>
                    Disconnect
                </button>
            ) : (
                <button color="primary"
                    onClick={() => activateBrowserWallet()}>
                    Connect
                </button>
            )
            }
        </div>
    )


}