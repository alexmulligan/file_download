from stellar_sdk import Keypair, Server, TransactionBuilder, Network
from os import listdir

# initialization code to connect to Stellar network and load account to send XLM from
server = Server(horizon_url="https://horizon.stellar.org")

keypair = Keypair.from_secret('YOUR SECRET KEY HERE')  # You need to put your secret key here to send from your account

senderAccount = server.load_account(account_id=keypair.public_key)


def sendXLM(destinationAddress: str, amount: float):
    # Function to create a single transaction to send XLM to an address
    # 
    # destinationAddress: str - the public address to send XLM to
    # amount: float - the amount of XLM to send

    transaction = TransactionBuilder(
        source_account=senderAccount, network_passphrase=Network.PUBLIC_NETWORK_PASSPHRASE, base_fee=100
    ).add_text_memo("Your Memo Here").append_payment_op(
        destinationAddress, amount=str(amount), asset_code="XLM"
    ).set_timeout(30).build()

    transaction.sign(keypair)
    response = server.submit_transaction(transaction)

    return response


def readAddresses(filename: str):
    # Function to read addresses from a text file and return them as a list
    #
    # filename: str - the name of the text file where the addresses are stored; must be in the same folder as this script
    #                 example: "addresses.txt"

    result = []
    with open(filename, 'r') as f:
        for line in f:
            if line.strip() != '':
                result.append(line.strip())
    
    return result


def main():
    
    filename = "addresses.txt"  # change this if you want to call the file something else
    amountXLM = 0.01  # how much XLM you want to send to each address; change this if you want

    if filename in listdir():
        addresses = readAddresses(filename)

        for address in addresses:
            sendXLM(address, amountXLM)
            print(str(amountXLM) + ' XLM sent to ' + address)

        print("Payments sent successfully.")

    else:
        print('Error: File "' + filename + '" not found.')


if __name__ == '__main__':
    main()

