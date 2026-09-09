# Self-Deploy the Workshop Environment

Use Azure Cloud Shell in the Azure portal to deploy your own workshop environment.

## Step 1. Open Azure Cloud Shell

1. Go to the [Azure portal](https://portal.azure.com/) and sign in.
2. Select the **Cloud Shell** icon in the portal toolbar.
3. Select **PowerShell** when prompted.
4. If this is your first time using Cloud Shell, follow the prompts to create or select its storage.
5. Confirm that Cloud Shell is using the Azure subscription where you want to deploy the workshop resources.

## Step 2. Choose a resource group name and region

Before running the deployment, choose:

* A unique resource group name, such as `my-cosmos-workshop`.
* An Azure region available to your subscription, such as `westus3`.

If you do not have Contributor access at subscription scope, create the resource group first and ensure you have Owner access on it. The script deploys into an existing resource group at resource-group scope; subscription permissions are only required when the script must create the resource group.

Replace `<your-resource-group-name>` and `<your-region>` in the command below with your own values. Do not include the angle brackets.

## Step 3. Clone and deploy

Run these commands in the Cloud Shell PowerShell console:

```powershell
git clone https://github.com/GaryHopeMS/CosmosDB-Workshop-2026-Int
cd ./CosmosDB-Workshop-2026-Int/
./script/self-provisioning-user-environment.ps1 -NoFabric -Location <your-region> -ResourceGroupName <your-resource-group-name> -IsDocDB 0
```

For example:

```powershell
./script/self-provisioning-user-environment.ps1 -NoFabric -Location westus3 -ResourceGroupName my-cosmos-workshop -IsDocDB 0
```

## Step 4. Connect to the lab VM

A successful deployment returns output similar to this:

```text
Bastion shareable URL: https://bst-example.bastion.azure.com/api/shareable-url/00000000-0000-0000-0000-000000000000
VmAdminUsername: lab_exampleuser
VmAdminPassword: Example2*Password
```

Open the **Bastion shareable URL** in your browser. On the Bastion sign-in page, enter the **VmAdminUsername** and **VmAdminPassword** shown in your deployment output to connect to the workshop VM.

After signing in, accept the default options for all Windows first-time configuration prompts to finish setting up the desktop.

Open **Windows Terminal** in the lab VM, then create and open the `C:\data` directory:

```powershell
az login --identity
md \data
cd \data
git clone https://github.com/GaryHopeMS/CosmosDB-Workshop-2026-Int
cd .\CosmosDB-Workshop-2026-Int\
.\SetEnv.ps1
```
Open a new terminal window 

```powershell
cd \data\CosmosDB-Workshop-2026-Int\
code .
```

Treat the generated password as sensitive information. Do not share it or commit it to source control.

The deployment creates billable Azure resources. When you finish the workshop, remove the resource group if you no longer need it.

## Step 5: Choose C# or Python

Use one language consistently unless the trainer asks you to compare both.

### C# workflow

1. Open the lab's `before/csharp` folder.
2. Read `Instructions.md`.
3. Complete the marked steps in the source files.
4. Run the project from that folder:

```powershell
dotnet run
```

### Python workflow

1. Open the notebook under the lab's `before/python` folder in VS Code.
2. Select the preconfigured Python kernel if prompted.
3. Read and run the cells in order.
4. Complete each exercise cell before moving forward.

The `before` folders are your exercises. Use the matching `after` folder only
to compare your result or recover when the trainer directs you to do so.

## Step 6: Complete the labs in order

| Order | Lab | C# instructions | Python notebook | Outcome |
|-------|-----|-----------------|-----------------|---------|
| 1 | 1B SDK CRUD | [Instructions](../1B_SDK_CRUD/before/csharp/Instructions.md) | [Notebook](../1B_SDK_CRUD/before/python/1B_SDK_CRUD.ipynb) | Create, read, update, and delete Cosmos DB items |
| 2 | 1D1 Query Language | [Instructions](../1D1_Query_Language/before/csharp/Instructions.md) | [Notebook](../1D1_Query_Language/before/python/1D1_Query_Language.ipynb) | Run parameterized and partition-aware queries |
| 3 | 1D2 Indexing | [Instructions](../1D2_Indexing/before/csharp/Instructions.md) | [Notebook](../1D2_Indexing/before/python/1D2_Indexing.ipynb) | Measure the impact of indexing policies |
| 4 | 1E Data Modeling | [Instructions](../1E_Data_Modeling/before/csharp/Instructions.md) | [Notebook](../1E_Data_Modeling/before/python/1E_Data_Modeling.ipynb) | Model data and partition keys around access patterns |
| 5 | 2C Completions and Embeddings | [Instructions](../2C_Completions_Embeddings/before/csharp/Instructions.md) | [Notebook](../2C_Completions_Embeddings/before/python/2C_Completions_Embeddings.ipynb) | Call chat and embedding models |
| 6 | 2D Vector Search | [Instructions](../2D_Vector_Search/before/csharp/Instructions.md) | [Notebook](../2D_Vector_Search/before/python/2D_Vector_Search.ipynb) | Store vectors and perform semantic search |
| 7 | 2E RAG Pipeline | [Instructions](../2E_RAG_Pipeline/before/csharp/Instructions.md) | [Notebook](../2E_RAG_Pipeline/before/python/2E_RAG_Pipeline.ipynb) | Build an end-to-end RAG pipeline |
| 8 | 2F Evaluation (optional) | [Instructions](../2F_Evaluation/before/csharp/Instructions.md) | [Notebook](../2F_Evaluation/before/python/2F_Evaluation.ipynb) | Score grounded responses with an LLM judge |
| 9 | 4A Chat Memory | [Instructions](../4A_Chat_Memory/before/csharp/Instructions.md) | [Notebook](../4A_Chat_Memory/before/python/4A_Chat_Memory.ipynb) | Persist multi-turn chat history in Cosmos DB |
| 10 | 4B Fabric Analytics (optional) | [Fabric instructions](../4B_Fabric_Mirror_Analytics/4B_Fabric_Mirror_Analytics_Instructions.md) | [Fabric instructions](../4B_Fabric_Mirror_Analytics/4B_Fabric_Mirror_Analytics_Instructions.md) | Mirror and analyze conversation history |

> [!IMPORTANT]
> Lab 2F uses data created by Lab 2E. Lab 4B uses conversation data created by
> Lab 4A and requires a Fabric workspace prepared by the trainer.

## Step 7: Finish your session

1. Remove the resource group if you no longer need it.

The deployment creates billable Azure resources. When you finish the workshop, remove the resource group if you no longer need it.
