import argparse
import math
import tempfile
from pathlib import Path

import graph_tool.all as gt
import networkx as nx
import numpy as np
import pandas as pd


def extract_position_and_control_points(graph: gt.Graph):
    state = gt.minimize_nested_blockmodel_dl(graph)
    hierarchy_tree = gt.get_hierarchy_tree(state)[0]
    last_vertex = list(hierarchy_tree.vertices())[-1]
    tree_start_pos = pos = gt.radial_tree_layout(hierarchy_tree, last_vertex)
    control_points = gt.get_hierarchy_control_points(
        graph, hierarchy_tree, tree_start_pos
    )
    pos = graph.own_property(tree_start_pos)

    return pos, control_points


def convert_to_gt_graph(adjacancy_matrix: np.ndarray):
    with tempfile.NamedTemporaryFile(suffix=".gml") as tmp:
        G: nx.Graph = nx.from_numpy_array(adjacancy_matrix)
        nx.write_gml(G, path=tmp.name)
        return gt.load_graph(tmp.name)


def main(input_path: Path, labels_path: Path, output_path: Path):
    adj_matrix = np.load(input_path)
    adj_matrix = np.nan_to_num(adj_matrix)

    graph = convert_to_gt_graph(adj_matrix)
    pos, control_points = extract_position_and_control_points(graph)

    names = pd.read_csv(labels_path)["Gene name"].tolist()
    name_map = graph.new_vp("string")
    for i, v in enumerate(graph.vertices()):
        name_map[v] = names[i]

    text_rot = graph.new_vertex_property("double")
    graph.vertex_properties["text_rot"] = text_rot
    for v in graph.vertices():
        if pos[v][0] > 0:
            text_rot[v] = math.atan(pos[v][1] / pos[v][0])
        else:
            text_rot[v] = math.pi + math.atan(pos[v][1] / pos[v][0])

    gt.graph_draw(
        graph,
        pos=pos,
        bg_color=[1, 1, 1, 1],
        vertex_size=30,
        vertex_anchor=0,
        vertex_text=name_map,
        vertex_text_rotation=graph.vertex_properties["text_rot"],
        vertex_text_position=0,
        vertex_text_color=[0, 0, 0, 1],
        vertex_font_size=14,
        edge_control_points=control_points,
        edge_color=[0, 0, 0, 0.2],
        output_size=[3840, 3840],
        output=output_path,
        fmt="png",
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input", type=str, help="Path to network matrix", required=True
    )
    parser.add_argument(
        "--output", type=str, help="Path to output image", required=True
    )
    parser.add_argument(
        "--labels",
        type=str,
        help="Path to labels csv (default: Labels for 21. chromosome)",
        required=True,
        default="ch21_names.csv",
    )

    args = parser.parse_args()

    main(Path(args.input), Path(args.labels), Path(args.output))
