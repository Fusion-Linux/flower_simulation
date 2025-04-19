## Tutorial

Running this example is easy. For a more detailed step-by-step guide, including more useful material, refer to the detailed guide in the following section.

```bash

# Generate docker compose file
python helpers/generate_docker_compose.py # by default will configure to use 2 clients for 100 rounds

# Build docker images
docker-compose build

# Launch everything
docker-compose up
```

Go to `http://localhost:3000` to see the Graphana dashboard showing system-level and application-level metrics.

To stop all containers, open a new terminal and `cd` into this directory, then run `docker-compose down`. Alternatively, you can do `ctrl+c` on the same terminal and then run `docker-compose down` to ensure everything is terminated.

## Running the Example (detailed)

### Step 1: Configure Docker Compose

Execute the following command to run the `helpers/generate_docker_compose.py` script. This script creates the docker-compose configuration needed to set up the environment.

```bash
python helpers/generate_docker_compose.py
```

Within the script, specify the number of clients (`total_clients`) and resource limitations for each client in the `client_configs` array. You can adjust the number of rounds by passing `--num_rounds` to the above command.

### Step 2: Build and Launch Containers

1. **Execute Initialization Script**:

   - To build the Docker images and start the containers, use the following command:

     ```bash
     # this is the only command you need to execute to run the entire example
     docker-compose up
     ```

   - If you make any changes to the Dockerfile or other configuration files, you should rebuild the images to reflect these changes. This can be done by adding the `--build` flag to the command:

     ```bash
     docker-compose up --build
     ```

   - The `--build` flag instructs Docker Compose to rebuild the images before starting the containers, ensuring that any code or configuration changes are included.

   - To stop all services, you have two options:

     - Run `docker-compose down` in another terminal if you are in the same directory. This command will stop and remove the containers, networks, and volumes created by `docker-compose up`.
     - Press `Ctrl+C` once in the terminal where `docker-compose up` is running. This will stop the containers but won't remove them or the networks and volumes they use.

2. **Services Startup**:

   - Several services will automatically launch as defined in your `docker-compose.yml` file:

     - **Monitoring Services**: Prometheus for metrics collection, Cadvisor for container monitoring, and Grafana for data visualization.
     - **Flower Federated Learning Environment**: The Flower server and client containers are initialized and start running.

   - After launching the services, verify that all Docker containers are running correctly by executing the `docker ps` command. Here's an example output:

     ```bash
     ➜  ~ docker ps
     CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS                 PORTS                                                              NAMES
     9f05820eba45   flower-via-docker-compose-client2   "python client.py --…"   50 seconds ago   Up 48 seconds   0.0.0.0:6002->6002/tcp                                                   client2
     a0333715d504   flower-via-docker-compose-client1   "python client.py --…"   50 seconds ago   Up 48 seconds   0.0.0.0:6001->6001/tcp                                                   client1
     0da2bf735965   flower-via-docker-compose-server    "python server.py --…"   50 seconds ago   Up 48 seconds   0.0.0.0:6000->6000/tcp, 0.0.0.0:8000->8000/tcp, 0.0.0.0:8265->8265/tcp   server
     c57ef50657ae   grafana/grafana:latest              "/run.sh --config=/e…"   50 seconds ago   Up 49 seconds   0.0.0.0:3000->3000/tcp                                                   grafana
     4f274c2083dc   prom/prometheus:latest              "/bin/prometheus --c…"   50 seconds ago   Up 49 seconds   0.0.0.0:9090->9090/tcp                                                   prometheus
     e9f4c9644a1c   gcr.io/cadvisor/cadvisor:v0.47.0    "/usr/bin/cadvisor -…"   50 seconds ago   Up 49 seconds   0.0.0.0:8080->8080/tcp                                                   cadvisor
     ```

   - To monitor the resource utilization of your containers in real-time and see the limits imposed in the Docker Compose file, you can use the `docker stats` command. This command provides a live stream of container CPU, memory, and network usage statistics.

     ```bash
     ➜  ~ docker stats
     CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O         PIDS
     9f05820eba45   client2      104.44%   1.968GiB / 6GiB       32.80%    148MB / 3.22MB    0B / 284MB        82
     a0333715d504   client1      184.69%   1.498GiB / 3GiB       49.92%    149MB / 2.81MB    1.37MB / 284MB    82
     0da2bf735965   server       0.12%     218.5MiB / 15.61GiB   1.37%     1.47MB / 2.89MB   2.56MB / 2.81MB   45
     c57ef50657ae   grafana      0.24%     96.19MiB / 400MiB     24.05%    18.9kB / 3.79kB   77.8kB / 152kB    20
     4f274c2083dc   prometheus   1.14%     52.73MiB / 500MiB     10.55%    6.79MB / 211kB    1.02MB / 1.31MB   15
     e9f4c9644a1c   cadvisor     7.31%     32.14MiB / 500MiB     6.43%     139kB / 6.66MB    500kB / 0B        18
     ```

3. **Automated Grafana Configuration**:

   - Grafana is configured to load pre-defined data sources and dashboards for immediate monitoring, facilitated by provisioning files. The provisioning files include `prometheus-datasource.yml` for data sources, located in the `./config/provisioning/datasources` directory, and `dashboard_index.json` for dashboards, in the `./config/provisioning/dashboards` directory. The `grafana.ini` file is also tailored to enhance user experience:
     - **Admin Credentials**: We provide default admin credentials in the `grafana.ini` configuration, which simplifies access by eliminating the need for users to go through the initial login process.
     - **Default Dashboard Path**: A default dashboard path is set in `grafana.ini` to ensure that the dashboard with all the necessary panels is rendered when Grafana is accessed.

   These files and settings are directly mounted into the Grafana container via Docker Compose volume mappings. This setup guarantees that upon startup, Grafana is pre-configured for monitoring, requiring no additional manual setup.

4. **Begin Training Process**:

   - The federated learning training automatically begins once all client containers are successfully connected to the Flower server. This synchronizes the learning process across all participating clients.

By following these steps, you will have a fully functional federated learning environment with device heterogeneity and monitoring capabilities.

## Model Training and Dataset Integration

### Data Pipeline with FLWR-Datasets

We have integrated [`flwr-datasets`](https://flower.ai/docs/datasets/) into our data pipeline, which is managed within the `load_data.py` file in the `helpers/` directory. This script facilitates standardized access to datasets across the federated network and incorporates a `data_sampling_percentage` argument. This argument allows users to specify the percentage of the dataset to be used for training and evaluation, accommodating devices with lower memory capabilities to prevent Out-of-Memory (OOM) errors.

### Model Selection and Dataset

For the federated learning system, we have selected the MobileNet model due to its efficiency in image classification tasks. The model is trained and evaluated on the CIFAR-10 dataset. The combination of MobileNet and CIFAR-10 is ideal for demonstrating the capabilities of our federated learning solution in a heterogeneous device environment.

- **MobileNet**: A streamlined architecture for mobile and embedded devices that balances performance and computational cost.
- **CIFAR-10 Dataset**: A standard benchmark dataset for image classification, containing various object classes that pose a comprehensive challenge for the learning model.

By integrating these components, our framework is well-prepared to handle the intricacies of training over a distributed network with varying device capabilities and data availability.

### Generating Training Reports

After completing the federated learning training, you can generate a comprehensive PDF report of the training results. The report includes:

- Model configuration details
- Training progress visualizations
- Final performance metrics
- System resource utilization

To generate the report:

1. **After Training Completion**:
   ```bash
   docker-compose --profile report up report-generator
   ```

2. **View the Report**:
   - The report will be generated as `federated_learning_report.pdf` in your project directory
   - Contains visualizations from Prometheus metrics
   - Includes final model performance statistics

The report generator service is configured to:
- Access training metrics from Prometheus
- Create detailed visualizations of the training process
- Generate a professional PDF document suitable for documentation
- Automatically clean up temporary files after report generation

