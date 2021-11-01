import React, { useState, useEffect } from 'react'
import { formatUnits } from '@ethersproject/units'
import { Button, CircularProgress, Input, Snackbar } from '@material-ui/core'
import { useEthers, useTokenBalance, useNotifications } from '@usedapp/core'
import { Alert } from '@material-ui/lab'
import { Token, } from '../Main'
import { useStakeTokens } from '../../hooks/useStakeTokens'
import { utils } from 'ethers'

interface StakeFormProps {
    token: Token
}

export const StakeForm = ({ token }: StakeFormProps) => {

    const { address: tokenAddress, name } = token
    const { account } = useEthers()
    const tokenBalance = useTokenBalance(tokenAddress, account)
    const formattedTokenBalance: number = tokenBalance ? parseFloat(formatUnits(tokenBalance, 18)) : 0
    const { notifications } = useNotifications()

    const [amount, setAmount] = React.useState<number | string | Array<number | string>>('');

    const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const newAmount = event.target.value == "" ? "" : Number(event.target.value);
        setAmount(newAmount);
        console.log(newAmount);
    }

    const { approveAndStake, state: approveAndStakeErc20State } = useStakeTokens(tokenAddress)

    const handleStakeSubmit = () => {
        const amountAsWei = utils.parseEther(amount.toString())
        return approveAndStake(amountAsWei.toString())
    }

    const isMining = approveAndStakeErc20State.status === 'Mining'
    const [showErc20ApprovalSuccess, setShowErc20ApprovalSuccess] = useState(false)
    const [showStakeTokenSuccess, setStakeTokenSuccess] = useState(false)
    const handleCloseSnack = () => {
        setShowErc20ApprovalSuccess(false)
        setStakeTokenSuccess(false)
    }

    useEffect(() => {
        if (notifications.filter(
            notification =>
                notification.type === "transactionSucceed" &&
                notification.transactionName === "Approve ERC20 transfer"
        ).length > 0
        ) {
            setShowErc20ApprovalSuccess(true)
            setStakeTokenSuccess(false)
        }

        if (notifications.filter(
            notification =>
                notification.type === "transactionSucceed" &&
                notification.transactionName === "Stake Tokens"
        ).length > 0
        ) {
            setShowErc20ApprovalSuccess(false)
            setStakeTokenSuccess(true)
        }

    }, [notifications, showErc20ApprovalSuccess, showStakeTokenSuccess])

    return (
        <>
            <div>
                <Input onChange={handleInputChange} />
                <Button
                    onClick={handleStakeSubmit}
                    color="primary"
                    size="large"
                    disabled={isMining}
                >
                    {isMining ? <CircularProgress size={26} /> : "Stake !"}
                </Button>
            </div>
            <Snackbar
                open={showErc20ApprovalSuccess}
                autoHideDuration={5000}
                onClose={handleCloseSnack}>
                <Alert onClose={handleCloseSnack} severity="success">
                    ERC-20 token transfer approved!
                </Alert>

            </Snackbar>
            <Snackbar
                open={showStakeTokenSuccess}
                autoHideDuration={5000}
                onClose={handleCloseSnack}>
                <Alert onClose={handleCloseSnack} severity="success">
                    Tokens staked !
                </Alert>

            </Snackbar>

        </>

    )

}