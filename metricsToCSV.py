import os
import scipy.io
import pandas as pd
import numpy as np

def process_timestep_logs(timestep_logs):
    """Process timestepLogs to extract throughput and goodput for each RNTI."""
    throughput_goodput = {}

    for entry in timestep_logs:
        for row in entry:
            if isinstance(row, (list, np.ndarray)) and len(row) > 13:  # Ensure row has enough columns
                try:
                    # Extract throughput and goodput arrays
                    direction = str(row[4].item() if isinstance(row[4], np.ndarray) else row[4])
                    throughput_array = row[12]  # Throughput is at index 12
                    goodput_array = row[13]  # Goodput is at index 13

                    # Check if throughput_array and goodput_array are valid arrays
                    if isinstance(throughput_array, np.ndarray):
                        throughput_array = throughput_array.flatten()  # Convert to 1D
                    if isinstance(goodput_array, np.ndarray):
                        goodput_array = goodput_array.flatten()  # Convert to 1D

                    # Iterate through all UEs (assumed to match by index)
                    for rnti, (throughput, goodput) in enumerate(zip(throughput_array, goodput_array), start=1):
                        if rnti not in throughput_goodput:
                            throughput_goodput[rnti] = {
                                "DL_throughput": 0,
                                "DL_goodput": 0,
                                "UL_throughput": 0,
                                "UL_goodput": 0,
                            }

                        # Convert throughput and goodput from bytes to bits (multiply by 8)
                        throughput_bits = throughput * 8
                        goodput_bits = goodput * 8

                        # Accumulate throughput and goodput based on direction
                        if direction == 'DL':
                            throughput_goodput[rnti]["DL_throughput"] += throughput_bits
                            throughput_goodput[rnti]["DL_goodput"] += goodput_bits
                        elif direction == 'UL':
                            throughput_goodput[rnti]["UL_throughput"] += throughput_bits
                            throughput_goodput[rnti]["UL_goodput"] += goodput_bits

                except Exception as e:
                    print(f"Skipping invalid timestep row: {row}, error: {e}")
                    continue  # Skip invalid rows

    return throughput_goodput


def process_scheduling_logs(scheduling_logs):
    """Process SchedulingAssignmentLogs and compute metrics."""
    metrics = {}

    for entry in scheduling_logs:
        for row in entry:
            if isinstance(row, (list, np.ndarray)) and len(row) > 12:  # Validate row structure
                try:
                    # Extract and flatten scalar fields
                    rnti = int(row[0].item() if isinstance(row[0], np.ndarray) else row[0])
                    direction = str(row[3].item() if isinstance(row[3], np.ndarray) else row[3])
                    num_sym = int(row[6].item() if isinstance(row[6], np.ndarray) else row[6])
                    mcs = int(row[7].item() if isinstance(row[7], np.ndarray) else row[7])

                    # Extract transmission type and ensure it's valid
                    tx_type = (
                        row[12].item().strip()
                        if isinstance(row[12], np.ndarray) and isinstance(row[12].item(), str)
                        else row[12].strip()
                        if isinstance(row[12], str)
                        else None
                    )
                    if tx_type is None or tx_type not in ['newTx', 'reTx']:
                        raise ValueError(f"Invalid tx_type: {tx_type}")

                except (ValueError, TypeError, IndexError, AttributeError) as e:
                    print(f"Skipping invalid scheduling row: {row}, error: {e}")
                    continue  # Skip invalid rows

                if rnti not in metrics:
                    metrics[rnti] = {
                        "numDLTotal": 0,
                        "numDLnew": 0,
                        "numReTx_DL": 0,
                        "avgMCS_DL": [],
                        "numULTotal": 0,
                        "numULnew": 0,
                        "numReTx_UL": 0,
                        "avgMCS_UL": [],
                        "DL_throughput": 0,
                        "DL_goodput": 0,
                        "UL_throughput": 0,
                        "UL_goodput": 0,
                    }

                # Count DL/UL metrics based on `tx_type` and `direction`
                if direction == "DL":
                    metrics[rnti]["numDLTotal"] += 1
                    if tx_type == "newTx":
                        metrics[rnti]["numDLnew"] += 1
                    elif tx_type == "reTx":
                        metrics[rnti]["numReTx_DL"] += 1
                    metrics[rnti]["avgMCS_DL"].append(mcs)
                elif direction == "UL":
                    metrics[rnti]["numULTotal"] += 1
                    if tx_type == "newTx":
                        metrics[rnti]["numULnew"] += 1
                    elif tx_type == "reTx":
                        metrics[rnti]["numReTx_UL"] += 1
                    metrics[rnti]["avgMCS_UL"].append(mcs)

    # Calculate averages
    for rnti, data in metrics.items():
        data["avgMCS_DL"] = np.mean(data["avgMCS_DL"]) if data["avgMCS_DL"] else 0
        data["avgMCS_UL"] = np.mean(data["avgMCS_UL"]) if data["avgMCS_UL"] else 0

    return metrics

def process_mat_file(filepath):
    """Load and process a .mat file."""
    try:
        mat_data = scipy.io.loadmat(filepath)

        if "simulationLogs" in mat_data:
            simulation_logs = mat_data["simulationLogs"][0][0]

            # Extract and process scheduling logs
            scheduling_logs = simulation_logs["SchedulingAssignmentLogs"]
            scheduling_data = [entry[0] for entry in scheduling_logs if len(entry) > 0]
            metrics = process_scheduling_logs(scheduling_data)

            # Extract and process timestep logs
            timestep_logs = simulation_logs["TimeStepLogs"]
            timestep_data = [entry[0] for entry in timestep_logs if len(entry) > 0]
            throughput_goodput = process_timestep_logs(timestep_data)

            # Integrate throughput and goodput into metrics
            for rnti, tg_data in throughput_goodput.items():
                if rnti in metrics:
                    metrics[rnti]["DL_throughput"] = tg_data["DL_throughput"]
                    metrics[rnti]["DL_goodput"] = tg_data["DL_goodput"]
                    metrics[rnti]["UL_throughput"] = tg_data["UL_throughput"]
                    metrics[rnti]["UL_goodput"] = tg_data["UL_goodput"]

            return metrics
        else:
            print(f"No simulationLogs found in {filepath}")
            return None
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return None


def save_metrics_to_csv(metrics, output_file):
    """Save computed DL/UL metrics and timestep logs to a CSV file."""
    rows = []
    for rnti, data in metrics.items():
        rows.append({
            "RNTI": rnti,
            "numDLTotal": data["numDLTotal"],
            "numDLnew": data["numDLnew"],
            "numReTx_DL": data["numReTx_DL"],
            "avgMCS_DL": round(data["avgMCS_DL"], 2),
            "numULTotal": data["numULTotal"],
            "numULnew": data["numULnew"],
            "numReTx_UL": data["numReTx_UL"],
            "avgMCS_UL": round(data["avgMCS_UL"], 2),
            "DL_throughput (bits)": round(data["DL_throughput"], 2),
            "DL_goodput (bits)": round(data["DL_goodput"], 2),
            "UL_throughput (bits)": round(data["UL_throughput"], 2),
            "UL_goodput (bits)": round(data["UL_goodput"], 2),
        })

    # Convert to DataFrame and save
    df = pd.DataFrame(rows)
    df.to_csv(output_file, index=False)
    print(f"Saved metrics to {output_file}")


def process_directory(root_dir):
    """Recursively process .mat files in the directory."""
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith("simulationMetrics.mat"):
                filepath = os.path.join(subdir, file)
                print(f"Processing file: {filepath}")
                metrics = process_mat_file(filepath)
                if metrics:
                    output_file = os.path.join(subdir, "processed_metrics.csv")
                    save_metrics_to_csv(metrics, output_file)


# Main
if __name__ == "__main__":
    root_directory = "./Run1"  # Change this to the root directory of your files
    process_directory(root_directory)